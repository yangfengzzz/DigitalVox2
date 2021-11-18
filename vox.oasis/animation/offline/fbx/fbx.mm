//
//  fbx.cpp
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/18.
//

#include "fbx.hpp"
#include "../../maths/simd_math.h"
#include <iostream>

FbxManagerInstance::FbxManagerInstance() : fbx_manager_(nullptr) {
    // Instantiate Fbx manager, mostly a memory manager.
    fbx_manager_ = FbxManager::Create();

    // Logs SDK version.
    std::cout << "FBX importer version " << fbx_manager_->GetVersion()
              << "." << std::endl;
}

FbxManagerInstance::~FbxManagerInstance() {
    // Destroy the manager and all associated objects.
    fbx_manager_->Destroy();
    fbx_manager_ = nullptr;
}

FbxDefaultIOSettings::FbxDefaultIOSettings(const FbxManagerInstance &_manager)
        : io_settings_(nullptr) {
    io_settings_ = FbxIOSettings::Create(_manager, IOSROOT);
    io_settings_->SetBoolProp(IMP_FBX_MATERIAL, false);
    io_settings_->SetBoolProp(IMP_FBX_TEXTURE, false);
    io_settings_->SetBoolProp(IMP_FBX_MODEL, false);
    io_settings_->SetBoolProp(IMP_FBX_SHAPE, false);
    io_settings_->SetBoolProp(IMP_FBX_LINK, false);
    io_settings_->SetBoolProp(IMP_FBX_GOBO, false);
}

FbxDefaultIOSettings::~FbxDefaultIOSettings() {
    io_settings_->Destroy();
    io_settings_ = nullptr;
}

FbxAnimationIOSettings::FbxAnimationIOSettings(
        const FbxManagerInstance &_manager)
        : FbxDefaultIOSettings(_manager) {
}

FbxSkeletonIOSettings::FbxSkeletonIOSettings(const FbxManagerInstance &_manager)
        : FbxDefaultIOSettings(_manager) {
    settings()->SetBoolProp(IMP_FBX_ANIMATION, false);
}

FbxSceneLoader::FbxSceneLoader(const char *_filename, const char *_password,
        const FbxManagerInstance &_manager,
        const FbxDefaultIOSettings &_io_settings)
        : scene_(nullptr), converter_(nullptr) {
    // Create an importer.
    FbxImporter *importer = FbxImporter::Create(_manager, "ozz file importer");
    const bool initialized = importer->Initialize(_filename, -1, _io_settings);

    ImportScene(importer, initialized, _password, _manager, _io_settings);

    // Destroy the importer
    importer->Destroy();
}

FbxSceneLoader::FbxSceneLoader(FbxStream *_stream, const char *_password,
        const FbxManagerInstance &_manager,
        const FbxDefaultIOSettings &_io_settings)
        : scene_(nullptr), converter_(nullptr) {
    // Create an importer.
    FbxImporter *importer = FbxImporter::Create(_manager, "ozz stream importer");
    const bool initialized =
            importer->Initialize(_stream, nullptr, -1, _io_settings);

    ImportScene(importer, initialized, _password, _manager, _io_settings);

    // Destroy the importer
    importer->Destroy();
}

void FbxSceneLoader::ImportScene(FbxImporter *_importer,
        const bool _initialized, const char *_password,
        const FbxManagerInstance &_manager,
        const FbxDefaultIOSettings &_io_settings) {
    // Get the version of the FBX file format.
    int major, minor, revision;
    _importer->GetFileVersion(major, minor, revision);

    if (!_initialized)  // Problem with the file to be imported.
    {
        const FbxString error = _importer->GetStatus().GetErrorString();
        std::cerr << "FbxImporter initialization failed with error: "
                  << error.Buffer() << std::endl;

        if (_importer->GetStatus().GetCode() == FbxStatus::eInvalidFileVersion) {
            std::cerr << "FBX file version is " << major << "." << minor << "."
                      << revision << "." << std::endl;
        }
    } else {
        if (_importer->IsFBX()) {
            std::cout << "FBX file version is " << major << "." << minor << "."
                      << revision << "." << std::endl;
        }

        // Load the scene.
        scene_ = FbxScene::Create(_manager, "ozz scene");
        bool imported = _importer->Import(scene_);

        if (!imported &&  // The import file may have a password
                _importer->GetStatus().GetCode() == FbxStatus::ePasswordError) {
            _io_settings.settings()->SetStringProp(IMP_FBX_PASSWORD, _password);
            _io_settings.settings()->SetBoolProp(IMP_FBX_PASSWORD_ENABLE, true);

            // Retries to import the scene.
            imported = _importer->Import(scene_);

            if (!imported &&
                    _importer->GetStatus().GetCode() == FbxStatus::ePasswordError) {
                std::cerr << "Incorrect password." << std::endl;

                // scene_ will be destroyed because imported is false.
            }
        }

        // Setup axis and system converter.
        if (imported) {
            FbxGlobalSettings &settings = scene_->GetGlobalSettings();
            converter_ = new FbxSystemConverter(settings.GetAxisSystem(),
                    settings.GetSystemUnit());
        }

        // Clear the scene if import failed.
        if (!imported) {
            scene_->Destroy();
            scene_ = nullptr;
        }
    }
}

FbxSceneLoader::~FbxSceneLoader() {
    if (scene_) {
        scene_->Destroy();
        scene_ = nullptr;
    }

    if (converter_) {
        delete converter_;
        converter_ = nullptr;
    }
}

namespace {
    simd_float4x4 BuildAxisSystemMatrix(const FbxAxisSystem &_system) {
        int sign;
        simd_float4 up = [OZZFloat4 y_axis];
        simd_float4 at = [OZZFloat4 z_axis];

        // The EUpVector specifies which axis has the up and down direction in the
        // system (typically this is the Y or Z axis). The sign of the EUpVector is
        // applied to represent the direction (1 is up and -1 is down relative to the
        // observer).
        const FbxAxisSystem::EUpVector eup = _system.GetUpVector(sign);
        switch (eup) {
            case FbxAxisSystem::eXAxis: {
                up = [OZZFloat4 LoadWith:1.f * sign :0.f :0.f :0.f];
                // If the up axis is X, the remain two axes will be Y And Z, so the
                // ParityEven is Y, and the ParityOdd is Z
                if (_system.GetFrontVector(sign) == FbxAxisSystem::eParityEven) {
                    at = [OZZFloat4 LoadWith:0.f :1.f * sign :0.f :0.f];
                } else {
                    at = [OZZFloat4 LoadWith:0.f :0.f :1.f * sign :0.f];
                }
                break;
            }
            case FbxAxisSystem::eYAxis: {
                up = [OZZFloat4 LoadWith:0.f :1.f * sign :0.f :0.f];
                // If the up axis is Y, the remain two axes will X And Z, so the
                // ParityEven is X, and the ParityOdd is Z
                if (_system.GetFrontVector(sign) == FbxAxisSystem::eParityEven) {
                    at = [OZZFloat4 LoadWith:1.f * sign :0.f :0.f :0.f];
                } else {
                    at = [OZZFloat4 LoadWith:0.f :0.f :1.f * sign :0.f];
                }
                break;
            }
            case FbxAxisSystem::eZAxis: {
                up = [OZZFloat4 LoadWith:0.f :0.f :1.f * sign :0.f];
                // If the up axis is Z, the remain two axes will X And Y, so the
                // ParityEven is X, and the ParityOdd is Y
                if (_system.GetFrontVector(sign) == FbxAxisSystem::eParityEven) {
                    at = [OZZFloat4 LoadWith:1.f * sign :0.f :0.f :0.f];
                } else {
                    at = [OZZFloat4 LoadWith:0.f :1.f * sign :0.f :0.f];
                }
                break;
            }
            default: {
                assert(false && "Invalid FbxAxisSystem");
                break;
            }
        }

        // If the front axis and the up axis are determined, the third axis will be
        // automatically determined as the left one. The ECoordSystem enum is a
        // parameter to determine the direction of the third axis just as the
        // EUpVector sign. It determines if the axis system is right-handed or
        // left-handed just as the enum values.
        SimdFloat4 right;
        if (_system.GetCoorSystem() == FbxAxisSystem::eRightHanded) {
            right = [OZZFloat4 Cross3With:up :at];
        } else {
            right = [OZZFloat4 Cross3With:at :up];
        }

        const simd_float4x4 matrix = {
                {right, up, at, [OZZFloat4 w_axis]}};

        return matrix;
    }
}  // namespace

FbxSystemConverter::FbxSystemConverter(const FbxAxisSystem &_from_axis,
        const FbxSystemUnit &_from_unit) {
    // Build axis system conversion matrix.
    const simd_float4x4 from_matrix = BuildAxisSystemMatrix(_from_axis);

    // Finds unit conversion ratio to meters, where GetScaleFactor() is in cm.
    const float to_meters =
            static_cast<float>(_from_unit.GetScaleFactor()) * .01f;

    // Builds conversion matrices.
    convert_ = [OZZFloat4x4 MulWith:[OZZFloat4x4 InvertWith:from_matrix :nullptr] mat:[OZZFloat4x4 ScalingWith:[OZZFloat4 Load1With:to_meters]]];
    inverse_convert_ = [OZZFloat4x4 InvertWith:convert_ :nullptr];
    inverse_transpose_convert_ = [OZZFloat4x4 TransposeWith:inverse_convert_];
}

simd_float4x4 FbxSystemConverter::ConvertMatrix(const FbxAMatrix &_m) const {
    const simd_float4x4 m = {{
            [OZZFloat4 LoadWith:
                    static_cast<float>(_m[0][0]) :static_cast<float>(_m[0][1]) :
                    static_cast<float>(_m[0][2]) :static_cast<float>(_m[0][3])],
            [OZZFloat4 LoadWith:
                    static_cast<float>(_m[1][0]) :static_cast<float>(_m[1][1]) :
                    static_cast<float>(_m[1][2]) :static_cast<float>(_m[1][3])],
            [OZZFloat4 LoadWith:
                    static_cast<float>(_m[2][0]) :static_cast<float>(_m[2][1]) :
                    static_cast<float>(_m[2][2]) :static_cast<float>(_m[2][3])],
            [OZZFloat4 LoadWith:
                    static_cast<float>(_m[3][0]) :static_cast<float>(_m[3][1]) :
                    static_cast<float>(_m[3][2]) :static_cast<float>(_m[3][3])],
    }};
    return [OZZFloat4x4 MulWith:[OZZFloat4x4 MulWith:convert_ mat:m] mat:inverse_convert_];
}

simd_float4 FbxSystemConverter::ConvertPoint(const FbxVector4 &_p) const {
    const simd_float4 p_in = [OZZFloat4 LoadWith:
            static_cast<float>(_p[0]) :static_cast<float>(_p[1]) :
            static_cast<float>(_p[2]) :1.f];
    const simd_float4 p_out = [OZZFloat4x4 MulWith:convert_ vec:p_in];
    return p_out;
}

simd_float4 FbxSystemConverter::ConvertVector(const FbxVector4 &_p) const {
    const simd_float4 p_in = [OZZFloat4 LoadWith:
            static_cast<float>(_p[0]) :static_cast<float>(_p[1]) :
            static_cast<float>(_p[2]) :0.f];
    const simd_float4 p_out = [OZZFloat4x4 MulWith:inverse_transpose_convert_ vec:p_in];
    return p_out;
}
