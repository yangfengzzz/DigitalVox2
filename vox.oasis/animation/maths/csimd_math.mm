//
//  simd_math.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

#import "csimd_math.h"
#import "simd_math.h"

@implementation OZZFloat4 {

}

+ (SimdFloat4)zero {
    return ozz::math::simd_float4::zero();
}

+ (SimdFloat4)one {
    return ozz::math::simd_float4::one();
}

+ (SimdFloat4)x_axis {
    return ozz::math::simd_float4::x_axis();
}

+ (SimdFloat4)y_axis {
    return ozz::math::simd_float4::y_axis();
}

+ (SimdFloat4)z_axis {
    return ozz::math::simd_float4::z_axis();
}

+ (SimdFloat4)w_axis {
    return ozz::math::simd_float4::w_axis();
}

+ (SimdFloat4)LoadWith:(float)_x :(float)_y :(float)_z :(float)_w {
    return ozz::math::simd_float4::Load(_x, _y, _z, _w);
}

+ (SimdFloat4)LoadXWith:(float)_x {
    return ozz::math::simd_float4::LoadX(_x);
}

+ (SimdFloat4)Load1With:(float)_x {
    return ozz::math::simd_float4::Load1(_x);
}

+ (SimdFloat4)LoadPtrWith:(const float *)_f {
    return ozz::math::simd_float4::LoadPtr(_f);
}

+ (SimdFloat4)LoadPtrUWith:(const float *)_f {
    return ozz::math::simd_float4::LoadPtrU(_f);
}

+ (SimdFloat4)LoadXPtrUWith:(const float *)_f {
    return ozz::math::simd_float4::LoadXPtrU(_f);
}

+ (SimdFloat4)Load1PtrUWith:(const float *)_f {
    return ozz::math::simd_float4::Load1PtrU(_f);
}

+ (SimdFloat4)Load2PtrUWith:(const float *)_f {
    return ozz::math::simd_float4::Load2PtrU(_f);
}

+ (SimdFloat4)Load3PtrUWith:(const float *)_f {
    return ozz::math::simd_float4::Load3PtrU(_f);
}

+ (SimdFloat4)FromIntWith:(_SimdInt4)_i {
    return ozz::math::simd_float4::FromInt(_i);
}

+ (float)GetXWith:(_SimdFloat4)_v {
    return ozz::math::GetX(_v);
}

+ (float)GetYWith:(_SimdFloat4)_v {
    return ozz::math::GetY(_v);
}

+ (float)GetZWith:(_SimdFloat4)_v {
    return ozz::math::GetZ(_v);
}

+ (float)GetWWith:(_SimdFloat4)_v {
    return ozz::math::GetW(_v);
}

+ (SimdFloat4)SetXWith:(_SimdFloat4)_v :(_SimdFloat4)_f {
    return ozz::math::SetX(_v, _f);
}

+ (SimdFloat4)SetYWith:(_SimdFloat4)_v :(_SimdFloat4)_f {
    return ozz::math::SetY(_v, _f);
}

+ (SimdFloat4)SetZWith:(_SimdFloat4)_v :(_SimdFloat4)_f {
    return ozz::math::SetZ(_v, _f);
}

+ (SimdFloat4)SetWWith:(_SimdFloat4)_v :(_SimdFloat4)_f {
    return ozz::math::SetW(_v, _f);
}

+ (SimdFloat4)SetIWith:(_SimdFloat4)_v :(_SimdFloat4)_f :(int)_ith {
    return ozz::math::SetI(_v, _f, _ith);
}

+ (void)StorePtrWith:(_SimdFloat4)_v :(float *)_f {
    return ozz::math::StorePtr(_v, _f);
}

+ (void)Store1PtrWith:(_SimdFloat4)_v :(float *)_f {
    return ozz::math::Store1Ptr(_v, _f);
}

+ (void)Store2PtrWith:(_SimdFloat4)_v :(float *)_f {
    return ozz::math::Store2Ptr(_v, _f);
}

+ (void)Store3PtrWith:(_SimdFloat4)_v :(float *)_f {
    return ozz::math::Store3Ptr(_v, _f);
}

+ (void)StorePtrUWith:(_SimdFloat4)_v :(float *)_f {
    return ozz::math::StorePtrU(_v, _f);
}

+ (void)Store1PtrUWith:(_SimdFloat4)_v :(float *)_f {
    return ozz::math::Store1PtrU(_v, _f);
}

+ (void)Store2PtrUWith:(_SimdFloat4)_v :(float *)_f {
    return ozz::math::Store2PtrU(_v, _f);
}

+ (void)Store3PtrUWith:(_SimdFloat4)_v :(float *)_f {
    return ozz::math::Store3PtrU(_v, _f);
}

+ (SimdFloat4)SplatXWith:(_SimdFloat4)_v {
    return ozz::math::SplatX(_v);
}

+ (SimdFloat4)SplatYWith:(_SimdFloat4)_v {
    return ozz::math::SplatY(_v);
}

+ (SimdFloat4)SplatZWith:(_SimdFloat4)_v {
    return ozz::math::SplatZ(_v);
}

+ (SimdFloat4)SplatWWith:(_SimdFloat4)_v {
    return ozz::math::SplatW(_v);
}

+ (SimdFloat4)Swizzle3332With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<3, 3, 3, 2>(_v);
}

+ (SimdFloat4)Swizzle0122With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<0, 1, 2, 2>(_v);
}

+ (SimdFloat4)Swizzle0120With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<0, 1, 2, 0>(_v);
}

+ (SimdFloat4)Swizzle3330With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<3, 3, 3, 0>(_v);
}

+ (SimdFloat4)Swizzle1201With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<1, 2, 0, 1>(_v);
}

+ (SimdFloat4)Swizzle2011With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<2, 0, 1, 1>(_v);
}

+ (SimdFloat4)Swizzle2013With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<2, 0, 1, 3>(_v);
}

+ (SimdFloat4)Swizzle1203With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<1, 2, 0, 3>(_v);
}

+ (SimdFloat4)Swizzle0123With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<0, 1, 2, 3>(_v);
}

+ (SimdFloat4)Swizzle0101With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<0, 1, 0, 1>(_v);
}

+ (SimdFloat4)Swizzle2323With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<2, 3, 2, 3>(_v);
}

+ (SimdFloat4)Swizzle0011With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<0, 0, 1, 1>(_v);
}

+ (SimdFloat4)Swizzle2233With:(_SimdFloat4)_v {
    return ozz::math::Swizzle<2, 2, 3, 3>(_v);
}

+ (void)Transpose4x1With:(const SimdFloat4[4])_in :(SimdFloat4[1])_out {
    return ozz::math::Transpose4x1(_in, _out);
}

+ (void)Transpose1x4With:(const SimdFloat4[1])_in :(SimdFloat4[3])_out {
    return ozz::math::Transpose1x4(_in, _out);
}

+ (void)Transpose4x2With:(const SimdFloat4[4])_in :(SimdFloat4[2])_out {
    return ozz::math::Transpose4x2(_in, _out);
}

+ (void)Transpose2x4With:(const SimdFloat4[2])_in :(SimdFloat4[4])_out {
    return ozz::math::Transpose2x4(_in, _out);
}

+ (void)Transpose4x3With:(const SimdFloat4[4])_in :(SoaFloat3[1])_out {
    return ozz::math::Transpose4x3(_in, &_out[0].x);
}

+ (void)Transpose3x4With:(const SoaFloat3[1])_in :(SimdFloat4[4])_out {
    return ozz::math::Transpose3x4(&_in[0].x, _out);
}

+ (void)Transpose4x4With:(const SimdFloat4[4])_in toQuat:(SoaQuaternion[1])_out {
    return ozz::math::Transpose4x4(_in, &_out[0].x);
}

+ (void)Transpose4x4FromQuat:(const SoaQuaternion[1])_in :(SimdFloat4[4])_out {
    return ozz::math::Transpose4x4(&_in[0].x, _out);
}

+ (void)Transpose16x16With:(const SoaFloat4x4[1])_in :(simd_float4x4[4])_out {
    return ozz::math::Transpose16x16(&_in[0].cols[0].x, &_out[0].columns[0]);
}

+ (SimdFloat4)MAddWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c {
    return ozz::math::MAdd(_a, _b, _c);
}

+ (SimdFloat4)MSubWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c {
    return ozz::math::MSub(_a, _b, _c);
}

+ (SimdFloat4)NMAddWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c {
    return ozz::math::NMAdd(_a, _b, _c);
}

+ (SimdFloat4)NMSubWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c {
    return ozz::math::NMSub(_a, _b, _c);
}

+ (SimdFloat4)DivXWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::DivX(_a, _b);
}

+ (SimdFloat4)HAdd2With:(_SimdFloat4)_v {
    return ozz::math::HAdd2(_v);
}

+ (SimdFloat4)HAdd3With:(_SimdFloat4)_v {
    return ozz::math::HAdd3(_v);
}

+ (SimdFloat4)HAdd4With:(_SimdFloat4)_v {
    return ozz::math::HAdd4(_v);
}

+ (SimdFloat4)Dot2With:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::Dot2(_a, _b);
}

+ (SimdFloat4)Dot3With:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::Dot3(_a, _b);
}

+ (SimdFloat4)Dot4With:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::Dot4(_a, _b);
}

+ (SimdFloat4)Cross3With:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::Cross3(_a, _b);
}

+ (SimdFloat4)RcpEstWith:(_SimdFloat4)_v {
    return ozz::math::RcpEst(_v);
}

+ (SimdFloat4)RcpEstNRWith:(_SimdFloat4)_v {
    return ozz::math::RcpEstNR(_v);
}

+ (SimdFloat4)RcpEstXWith:(_SimdFloat4)_v {
    return ozz::math::RcpEstX(_v);
}

+ (SimdFloat4)RcpEstXNRWith:(_SimdFloat4)_v {
    return ozz::math::RcpEstXNR(_v);
}

+ (SimdFloat4)SqrtWith:(_SimdFloat4)_v {
    return ozz::math::Sqrt(_v);
}

+ (SimdFloat4)SqrtXWith:(_SimdFloat4)_v {
    return ozz::math::SqrtX(_v);
}

+ (SimdFloat4)RSqrtEstWith:(_SimdFloat4)_v {
    return ozz::math::RSqrtEst(_v);
}

+ (SimdFloat4)RSqrtEstNRWith:(_SimdFloat4)_v {
    return ozz::math::RSqrtEstNR(_v);
}

+ (SimdFloat4)RSqrtEstXWith:(_SimdFloat4)_v {
    return ozz::math::RSqrtEstX(_v);
}

+ (SimdFloat4)RSqrtEstXNRWith:(_SimdFloat4)_v {
    return ozz::math::RSqrtEstXNR(_v);
}

+ (SimdFloat4)AbsWith:(_SimdFloat4)_v {
    return ozz::math::Abs(_v);
}

+ (SimdInt4)SignWith:(_SimdFloat4)_v {
    return ozz::math::Sign(_v);
}

+ (SimdFloat4)Length2With:(_SimdFloat4)_v {
    return ozz::math::Length2(_v);
}

+ (SimdFloat4)Length3With:(_SimdFloat4)_v {
    return ozz::math::Length3(_v);
}

+ (SimdFloat4)Length4With:(_SimdFloat4)_v {
    return ozz::math::Length4(_v);
}

+ (SimdFloat4)Length2SqrWith:(_SimdFloat4)_v {
    return ozz::math::Length2Sqr(_v);
}

+ (SimdFloat4)Length3SqrWith:(_SimdFloat4)_v {
    return ozz::math::Length3Sqr(_v);
}

+ (SimdFloat4)Length4SqrWith:(_SimdFloat4)_v {
    return ozz::math::Length4Sqr(_v);
}

+ (SimdFloat4)Normalize2With:(_SimdFloat4)_v {
    return ozz::math::Normalize2(_v);
}

+ (SimdFloat4)Normalize3With:(_SimdFloat4)_v {
    return ozz::math::Normalize3(_v);
}

+ (SimdFloat4)Normalize4With:(_SimdFloat4)_v {
    return ozz::math::Normalize4(_v);
}

+ (SimdFloat4)NormalizeEst2With:(_SimdFloat4)_v {
    return ozz::math::NormalizeEst2(_v);
}

+ (SimdFloat4)NormalizeEst3With:(_SimdFloat4)_v {
    return ozz::math::NormalizeEst3(_v);
}

+ (SimdFloat4)NormalizeEst4With:(_SimdFloat4)_v {
    return ozz::math::NormalizeEst4(_v);
}

+ (SimdInt4)IsNormalized2With:(_SimdFloat4)_v {
    return ozz::math::IsNormalized2(_v);
}

+ (SimdInt4)IsNormalized3With:(_SimdFloat4)_v {
    return ozz::math::IsNormalized3(_v);
}

+ (SimdInt4)IsNormalized4With:(_SimdFloat4)_v {
    return ozz::math::IsNormalized4(_v);
}

+ (SimdInt4)IsNormalizedEst2With:(_SimdFloat4)_v {
    return ozz::math::IsNormalizedEst2(_v);
}

+ (SimdInt4)IsNormalizedEst3With:(_SimdFloat4)_v {
    return ozz::math::IsNormalizedEst3(_v);
}

+ (SimdInt4)IsNormalizedEst4With:(_SimdFloat4)_v {
    return ozz::math::IsNormalizedEst4(_v);
}

+ (SimdFloat4)NormalizeSafe2With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    return ozz::math::NormalizeSafe2(_v, _safe);
}

+ (SimdFloat4)NormalizeSafe3With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    return ozz::math::NormalizeSafe3(_v, _safe);
}

+ (SimdFloat4)NormalizeSafe4With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    return ozz::math::NormalizeSafe4(_v, _safe);
}

+ (SimdFloat4)NormalizeSafeEst2With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    return ozz::math::NormalizeSafeEst2(_v, _safe);
}

+ (SimdFloat4)NormalizeSafeEst3With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    return ozz::math::NormalizeSafeEst3(_v, _safe);
}

+ (SimdFloat4)NormalizeSafeEst4With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    return ozz::math::NormalizeSafeEst4(_v, _safe);
}

+ (SimdFloat4)LerpWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_alpha {
    return ozz::math::Lerp(_a, _b, _alpha);
}

+ (SimdFloat4)MinWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::Min(_a, _b);
}

+ (SimdFloat4)MaxWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::Max(_a, _b);
}

+ (SimdFloat4)Min0With:(_SimdFloat4)_v {
    return ozz::math::Min0(_v);
}

+ (SimdFloat4)Max0With:(_SimdFloat4)_v {
    return ozz::math::Max0(_v);
}

+ (SimdFloat4)ClampWith:(_SimdFloat4)_a :(_SimdFloat4)_v :(_SimdFloat4)_b {
    return ozz::math::Clamp(_a, _v, _b);
}

+ (SimdFloat4)SelectWith:(_SimdInt4)_b :(_SimdFloat4)_true :(_SimdFloat4)_false {
    return ozz::math::Select(_b, _true, _false);
}

+ (SimdInt4)CmpEqWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::CmpEq(_a, _b);
}

+ (SimdInt4)CmpNeWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::CmpNe(_a, _b);
}

+ (SimdInt4)CmpLtWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::CmpLt(_a, _b);
}

+ (SimdInt4)CmpLeWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::CmpLe(_a, _b);
}

+ (SimdInt4)CmpGtWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::CmpGt(_a, _b);
}

+ (SimdInt4)CmpGeWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return ozz::math::CmpGe(_a, _b);
}

+ (SimdFloat4)AndWith:(_SimdFloat4)_a float4:(_SimdFloat4)_b {
    return ozz::math::And(_a, _b);
}

+ (SimdFloat4)OrWith:(_SimdFloat4)_a float4:(_SimdFloat4)_b {
    return ozz::math::Or(_a, _b);
}

+ (SimdFloat4)XorWith:(_SimdFloat4)_a float4:(_SimdFloat4)_b {
    return ozz::math::Xor(_a, _b);
}

+ (SimdFloat4)AndWith:(_SimdFloat4)_a int4:(_SimdInt4)_b {
    return ozz::math::And(_a, _b);
}

+ (SimdFloat4)AndNotWith:(_SimdFloat4)_a :(_SimdInt4)_b {
    return ozz::math::AndNot(_a, _b);
}

+ (SimdFloat4)OrWith:(_SimdFloat4)_a int4:(_SimdInt4)_b {
    return ozz::math::Or(_a, _b);
}

+ (SimdFloat4)XorWith:(_SimdFloat4)_a int4:(_SimdInt4)_b {
    return ozz::math::Xor(_a, _b);
}

+ (SimdFloat4)CosWith:(_SimdFloat4)_v {
    return ozz::math::Cos(_v);
}

+ (SimdFloat4)CosXWith:(_SimdFloat4)_v {
    return ozz::math::CosX(_v);
}

+ (SimdFloat4)ACosWith:(_SimdFloat4)_v {
    return ozz::math::ACos(_v);
}

+ (SimdFloat4)ACosXWith:(_SimdFloat4)_v {
    return ozz::math::ACosX(_v);
}

+ (SimdFloat4)SinWith:(_SimdFloat4)_v {
    return ozz::math::Sin(_v);
}

+ (SimdFloat4)SinXWith:(_SimdFloat4)_v {
    return ozz::math::SinX(_v);
}

+ (SimdFloat4)ASinWith:(_SimdFloat4)_v {
    return ozz::math::ASin(_v);
}

+ (SimdFloat4)ASinXWith:(_SimdFloat4)_v {
    return ozz::math::ASinX(_v);
}

+ (SimdFloat4)TanWith:(_SimdFloat4)_v {
    return ozz::math::Tan(_v);
}

+ (SimdFloat4)TanXWith:(_SimdFloat4)_v {
    return ozz::math::TanX(_v);
}

+ (SimdFloat4)ATanWith:(_SimdFloat4)_v {
    return ozz::math::ATan(_v);
}

+ (SimdFloat4)ATanXWith:(_SimdFloat4)_v {
    return ozz::math::ATanX(_v);
}


@end

//MARK: - OZZInt4
@implementation OZZInt4 {

}

+ (SimdInt4)zero {
    return ozz::math::simd_int4::zero();
}

+ (SimdInt4)one {
    return ozz::math::simd_int4::one();
}

+ (SimdInt4)x_axis {
    return ozz::math::simd_int4::x_axis();
}

+ (SimdInt4)y_axis {
    return ozz::math::simd_int4::y_axis();
}

+ (SimdInt4)z_axis {
    return ozz::math::simd_int4::z_axis();
}

+ (SimdInt4)w_axis {
    return ozz::math::simd_int4::w_axis();
}

+ (SimdInt4)all_true {
    return ozz::math::simd_int4::all_true();
}

+ (SimdInt4)all_false {
    return ozz::math::simd_int4::all_false();
}

+ (SimdInt4)mask_sign {
    return ozz::math::simd_int4::mask_sign();
}

+ (SimdInt4)mask_sign_xyz {
    return ozz::math::simd_int4::mask_sign_xyz();
}

+ (SimdInt4)mask_sign_w {
    return ozz::math::simd_int4::mask_sign_w();
}

+ (SimdInt4)mask_not_sign {
    return ozz::math::simd_int4::mask_not_sign();
}

+ (SimdInt4)mask_ffff {
    return ozz::math::simd_int4::mask_ffff();
}

+ (SimdInt4)mask_0000 {
    return ozz::math::simd_int4::mask_0000();
}

+ (SimdInt4)mask_fff0 {
    return ozz::math::simd_int4::mask_fff0();
}

+ (SimdInt4)mask_f000 {
    return ozz::math::simd_int4::mask_f000();
}

+ (SimdInt4)mask_0f00 {
    return ozz::math::simd_int4::mask_0f00();
}

+ (SimdInt4)mask_00f0 {
    return ozz::math::simd_int4::mask_00f0();
}

+ (SimdInt4)mask_000f {
    return ozz::math::simd_int4::mask_000f();
}

+ (SimdInt4)LoadWithInt:(int)_x :(int)_y :(int)_z :(int)_w {
    return ozz::math::simd_int4::Load(_x, _y, _z, _w);
}

+ (SimdInt4)LoadXWithInt:(int)_x {
    return ozz::math::simd_int4::LoadX(_x);
}

+ (SimdInt4)Load1WithInt:(int)_x {
    return ozz::math::simd_int4::Load1(_x);
}

+ (SimdInt4)LoadWithBool:(bool)_x :(bool)_y :(bool)_z :(bool)_w {
    return ozz::math::simd_int4::Load(_x, _y, _z, _w);
}

+ (SimdInt4)LoadXWithBool:(bool)_x {
    return ozz::math::simd_int4::LoadX(_x);
}

+ (SimdInt4)Load1WithBool:(bool)_x {
    return ozz::math::simd_int4::Load1(_x);
}

+ (SimdInt4)LoadPtrWith:(const int *)_i {
    return ozz::math::simd_int4::LoadPtr(_i);
}

+ (SimdInt4)LoadXPtrWith:(const int *)_i {
    return ozz::math::simd_int4::LoadXPtr(_i);
}

+ (SimdInt4)Load1PtrWith:(const int *)_i {
    return ozz::math::simd_int4::Load1Ptr(_i);
}

+ (SimdInt4)Load2PtrWith:(const int *)_i {
    return ozz::math::simd_int4::Load2Ptr(_i);
}

+ (SimdInt4)Load3PtrWith:(const int *)_i {
    return ozz::math::simd_int4::Load3Ptr(_i);
}

+ (SimdInt4)LoadPtrUWith:(const int *)_i {
    return ozz::math::simd_int4::LoadPtrU(_i);
}

+ (SimdInt4)LoadXPtrUWith:(const int *)_i {
    return ozz::math::simd_int4::LoadXPtr(_i);
}

+ (SimdInt4)Load1PtrUWith:(const int *)_i {
    return ozz::math::simd_int4::Load1PtrU(_i);
}

+ (SimdInt4)Load2PtrUWith:(const int *)_i {
    return ozz::math::simd_int4::Load2PtrU(_i);
}

+ (SimdInt4)Load3PtrUWith:(const int *)_i {
    return ozz::math::simd_int4::Load3PtrU(_i);
}

+ (SimdInt4)FromFloatRoundWith:(_SimdFloat4)_f {
    return ozz::math::simd_int4::FromFloatRound(_f);
}

+ (SimdInt4)FromFloatTruncWith:(_SimdFloat4)_f {
    return ozz::math::simd_int4::FromFloatTrunc(_f);
}

+ (int)GetXWith:(_SimdInt4)_v {
    return ozz::math::GetX(_v);
}

+ (int)GetYWith:(_SimdInt4)_v {
    return ozz::math::GetY(_v);
}

+ (int)GetZWith:(_SimdInt4)_v {
    return ozz::math::GetZ(_v);
}

+ (int)GetWWith:(_SimdInt4)_v {
    return ozz::math::GetW(_v);
}

+ (SimdInt4)SetXWith:(_SimdInt4)_v :(_SimdInt4)_i {
    return ozz::math::SetX(_v, _i);
}

+ (SimdInt4)SetYWith:(_SimdInt4)_v :(_SimdInt4)_i {
    return ozz::math::SetY(_v, _i);
}

+ (SimdInt4)SetZWith:(_SimdInt4)_v :(_SimdInt4)_i {
    return ozz::math::SetZ(_v, _i);
}

+ (SimdInt4)SetWWith:(_SimdInt4)_v :(_SimdInt4)_i {
    return ozz::math::SetW(_v, _i);
}

+ (SimdInt4)SetIWith:(_SimdInt4)_v :(_SimdInt4)_i :(int)_ith {
    return ozz::math::SetI(_v, _i, _ith);
}

+ (void)StorePtrWith:(_SimdInt4)_v :(int *)_i {
    return ozz::math::StorePtr(_v, _i);
}

+ (void)Store1PtrWith:(_SimdInt4)_v :(int *)_i {
    return ozz::math::Store1Ptr(_v, _i);
}

+ (void)Store2PtrWith:(_SimdInt4)_v :(int *)_i {
    return ozz::math::Store2Ptr(_v, _i);
}

+ (void)Store3PtrWith:(_SimdInt4)_v :(int *)_i {
    return ozz::math::Store3Ptr(_v, _i);
}

+ (void)StorePtrUWith:(_SimdInt4)_v :(int *)_i {
    return ozz::math::StorePtrU(_v, _i);
}

+ (void)Store1PtrUWith:(_SimdInt4)_v :(int *)_i {
    return ozz::math::Store1PtrU(_v, _i);
}

+ (void)Store2PtrUWith:(_SimdInt4)_v :(int *)_i {
    return ozz::math::Store2PtrU(_v, _i);
}

+ (void)Store3PtrUWith:(_SimdInt4)_v :(int *)_i {
    return ozz::math::Store3PtrU(_v, _i);
}

+ (SimdInt4)SplatXWith:(_SimdInt4)_a {
    return ozz::math::SplatX(_a);
}

+ (SimdInt4)SplatYWith:(_SimdInt4)_a {
    return ozz::math::SplatY(_a);
}

+ (SimdInt4)SplatZWith:(_SimdInt4)_a {
    return ozz::math::SplatZ(_a);
}

+ (SimdInt4)SplatWWith:(_SimdInt4)_a {
    return ozz::math::SplatW(_a);
}

+ (SimdInt4)Swizzle0123With:(_SimdInt4)_v {
    return ozz::math::Swizzle<0, 1, 2, 3>(_v);
}

+ (int)MoveMaskWith:(_SimdInt4)_v {
    return ozz::math::MoveMask(_v);
}

+ (bool)AreAllTrueWith:(_SimdInt4)_v {
    return ozz::math::AreAllTrue(_v);
}

+ (bool)AreAllTrue3With:(_SimdInt4)_v {
    return ozz::math::AreAllTrue3(_v);
}

+ (bool)AreAllTrue2With:(_SimdInt4)_v {
    return ozz::math::AreAllTrue2(_v);
}

+ (bool)AreAllTrue1With:(_SimdInt4)_v {
    return ozz::math::AreAllTrue1(_v);
}

+ (bool)AreAllFalseWith:(_SimdInt4)_v {
    return ozz::math::AreAllFalse(_v);
}

+ (bool)AreAllFalse3With:(_SimdInt4)_v {
    return ozz::math::AreAllFalse3(_v);
}

+ (bool)AreAllFalse2With:(_SimdInt4)_v {
    return ozz::math::AreAllFalse2(_v);
}

+ (bool)AreAllFalse1With:(_SimdInt4)_v {
    return ozz::math::AreAllFalse1(_v);
}

+ (SimdInt4)HAdd2With:(_SimdInt4)_v {
    return ozz::math::HAdd2(_v);
}

+ (SimdInt4)HAdd3With:(_SimdInt4)_v {
    return ozz::math::HAdd3(_v);
}

+ (SimdInt4)HAdd4With:(_SimdInt4)_v {
    return ozz::math::HAdd4(_v);
}

+ (SimdInt4)AbsWith:(_SimdInt4)_v {
    return ozz::math::Abs(_v);
}

+ (SimdInt4)SignWith:(_SimdInt4)_v {
    return ozz::math::Sign(_v);
}

+ (SimdInt4)MinWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::Min(_a, _b);
}

+ (SimdInt4)MaxWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::Max(_a, _b);
}

+ (SimdInt4)Min0With:(_SimdInt4)_v {
    return ozz::math::Min0(_v);
}

+ (SimdInt4)Max0With:(_SimdInt4)_v {
    return ozz::math::Max0(_v);
}

+ (SimdInt4)ClampWith:(_SimdInt4)_a :(_SimdInt4)_v :(_SimdInt4)_b {
    return ozz::math::Clamp(_a, _v, _b);
}

+ (SimdInt4)SelectWith:(_SimdInt4)_b :(_SimdInt4)_true :(_SimdInt4)_false {
    return ozz::math::Select(_b, _true, _false);
}

+ (SimdInt4)AndWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::And(_a, _b);
}

+ (SimdInt4)AndNotWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::AndNot(_a, _b);
}

+ (SimdInt4)OrWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::Or(_a, _b);
}

+ (SimdInt4)XorWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::Xor(_a, _b);
}

+ (SimdInt4)NotWith:(_SimdInt4)_v {
    return ozz::math::Not(_v);
}

+ (SimdInt4)ShiftLWith:(_SimdInt4)_v :(int)_bits {
    return ozz::math::ShiftL(_v, _bits);
}

+ (SimdInt4)ShiftRWith:(_SimdInt4)_v :(int)_bits {
    return ozz::math::ShiftR(_v, _bits);
}

+ (SimdInt4)ShiftRuWith:(_SimdInt4)_v :(int)_bits {
    return ozz::math::ShiftRu(_v, _bits);
}

+ (SimdInt4)CmpEqWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::CmpEq(_a, _b);
}

+ (SimdInt4)CmpNeWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::CmpNe(_a, _b);
}

+ (SimdInt4)CmpLtWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::CmpLt(_a, _b);
}

+ (SimdInt4)CmpLeWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::CmpLe(_a, _b);
}

+ (SimdInt4)CmpGtWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::CmpGt(_a, _b);
}

+ (SimdInt4)CmpGeWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return ozz::math::CmpGe(_a, _b);
}


@end

//MARK: - OZZFloat4x4
@implementation OZZFloat4x4

+ (simd_float4x4)identity {
    return ozz::math::Float4x4::identity();
}

+ (simd_float4x4)TransposeWith:(simd_float4x4)_m {
    return ozz::math::Transpose(_m);
}

+ (simd_float4x4)InvertWith:(simd_float4x4)_m :(SimdInt4 *)_invertible {
    return ozz::math::Invert(_m, _invertible);
}

+ (simd_float4x4)TranslationWith:(_SimdFloat4)_v {
    return ozz::math::Float4x4::Translation(_v);
}

+ (simd_float4x4)ScalingWith:(_SimdFloat4)_v {
    return ozz::math::Float4x4::Scaling(_v);
}

+ (simd_float4x4)TranslateWith:(simd_float4x4)_m :(_SimdFloat4)_v {
    return ozz::math::Translate(_m, _v);
}

+ (simd_float4x4)ScaleWith:(simd_float4x4)_m :(_SimdFloat4)_v {
    return ozz::math::Scale(_m, _v);
}

+ (simd_float4x4)ColumnMultiplyWith:(simd_float4x4)_m :(_SimdFloat4)_v {
    return ozz::math::ColumnMultiply(_m, _v);
}

+ (SimdInt4)IsNormalizedWith:(simd_float4x4)_m {
    return ozz::math::IsNormalized(_m);
}

+ (SimdInt4)IsNormalizedEstWith:(simd_float4x4)_m {
    return ozz::math::IsNormalizedEst(_m);
}

+ (SimdInt4)IsOrthogonalWith:(simd_float4x4)_m {
    return ozz::math::IsOrthogonal(_m);
}

+ (SimdFloat4)ToQuaternionWith:(simd_float4x4)_m {
    return ozz::math::ToQuaternion(_m);
}

+ (bool)ToAffineWith:(simd_float4x4)_m :(SimdFloat4 *)_translation
        :(SimdFloat4 *)_quaternion :(SimdFloat4 *)_scale {
    return ozz::math::ToAffine(_m, _translation, _quaternion, _scale);
}

+ (simd_float4x4)FromEulerWith:(_SimdFloat4)_v {
    return ozz::math::Float4x4::FromEuler(_v);
}

+ (simd_float4x4)FromAxisAngleWith:(_SimdFloat4)_axis :(_SimdFloat4)_angle {
    return ozz::math::Float4x4::FromAxisAngle(_axis, _angle);
}

+ (simd_float4x4)FromQuaternionWith:(_SimdFloat4)_quaternion {
    return ozz::math::Float4x4::FromQuaternion(_quaternion);
}

+ (simd_float4x4)FromAffineWith:(_SimdFloat4)_translation
        :(_SimdFloat4)_quaternion
        :(_SimdFloat4)_scale {
    return ozz::math::Float4x4::FromAffine(_translation, _quaternion, _scale);
}

+ (SimdFloat4)TransformPointWith:(simd_float4x4)_m
        :(_SimdFloat4)_v {
    return ozz::math::TransformPoint(_m, _v);
}

+ (SimdFloat4)TransformVectorWith:(simd_float4x4)_m
        :(_SimdFloat4)_v {
    return ozz::math::TransformVector(_m, _v);
}

+ (SimdFloat4)MulWith:(simd_float4x4)_m
                  vec:(_SimdFloat4)_v {
    return ozz::math::operator*(_m, _v);
}

+ (simd_float4x4)MulWith:(simd_float4x4)_a
                     mat:(simd_float4x4)_b {
    return ozz::math::operator*(_a, _b);
}

+ (simd_float4x4)AddWith:(simd_float4x4)_a
        :(simd_float4x4)_b {
    return ozz::math::operator+(_a, _b);
}

+ (simd_float4x4)SubWith:(simd_float4x4)_a
        :(simd_float4x4)_b {
    return ozz::math::operator-(_a, _b);
}

@end

//MARK: - OZZMath
@implementation OZZMath

+ (uint16_t)FloatToHalfWith:(float)_f {
    return ozz::math::FloatToHalf(_f);
}

+ (float)HalfToFloatWith:(uint16_t)_h {
    return ozz::math::HalfToFloat(_h);
}

+ (SimdInt4)FloatToHalfWithSIMD:(_SimdFloat4)_f {
    return ozz::math::FloatToHalf(_f);
}

+ (SimdFloat4)HalfToFloatWithSIMD:(_SimdInt4)_h {
    return ozz::math::HalfToFloat(_h);
}

+ (int)FloatCastI32:(float)_f {
    union {
        float f;
        int i;
    } orx = {_f};
    return orx.i;
}

+ (uint)FloatCastU32:(float)_f {
    union {
        float f;
        unsigned int i;
    } orx = {_f};
    return orx.i;
}

@end
