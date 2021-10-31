//
//  simd_math.m
//  vox.oasis
//
//  Created by 杨丰 on 2021/10/30.
//

#import "simd_math.h"
#import "math_constant.h"

#define OZZ_SHUFFLE_PS1(_v, _m) _mm_shuffle_ps(_v, _v, _m)

#define OZZ_SSE_SPLAT_F(_v, _i) OZZ_SHUFFLE_PS1(_v, _MM_SHUFFLE(_i, _i, _i, _i))

#define OZZ_SSE_SPLAT_I(_v, _i) \
  _mm_shuffle_epi32(_v, _MM_SHUFFLE(_i, _i, _i, _i))

// _v.x + _v.y, _v.y, _v.z, _v.w
#define OZZ_SSE_HADD2_F(_v) _mm_add_ss(_v, OZZ_SSE_SPLAT_F(_v, 1))

// _v.x + _v.y + _v.z, _v.y, _v.z, _v.w
#define OZZ_SSE_HADD3_F(_v) \
  _mm_add_ss(_mm_add_ss(_v, OZZ_SSE_SPLAT_F(_v, 2)), OZZ_SSE_SPLAT_F(_v, 1))

// _v.x + _v.y + _v.z + _v.w, ?, ?, ?
#define OZZ_SSE_HADD4_F(_v, _r)                                    \
  do {                                                             \
    const __m128 haddxyzw = _mm_add_ps(_v, _mm_movehl_ps(_v, _v)); \
    _r = _mm_add_ss(haddxyzw, OZZ_SSE_SPLAT_F(haddxyzw, 1));       \
  } while (void(0), 0)

// dot2, ?, ?, ?
#define OZZ_SSE_DOT2_F(_a, _b, _r)               \
  do {                                           \
    const __m128 ab = _mm_mul_ps(_a, _b);        \
    _r = _mm_add_ss(ab, OZZ_SSE_SPLAT_F(ab, 1)); \
                                                 \
  } while (void(0), 0)

// dot3, ?, ?, ?
#define OZZ_SSE_DOT3_F(_a, _b, _r) \
  do {                             \
    _r = _mm_dp_ps(_a, _b, 0x7f);  \
  } while (void(0), 0)

// dot4, ?, ?, ?
#define OZZ_SSE_DOT4_F(_a, _b, _r) \
  do {                             \
    _r = _mm_dp_ps(_a, _b, 0xff);  \
  } while (void(0), 0)

#define OZZ_MADD(_a, _b, _c) _mm_add_ps(_mm_mul_ps(_a, _b), _c)
#define OZZ_MSUB(_a, _b, _c) _mm_sub_ps(_mm_mul_ps(_a, _b), _c)
#define OZZ_NMADD(_a, _b, _c) _mm_sub_ps(_c, _mm_mul_ps(_a, _b))
#define OZZ_NMSUB(_a, _b, _c) (-_mm_add_ps(_mm_mul_ps(_a, _b), _c))
#define OZZ_MADDX(_a, _b, _c) _mm_add_ss(_mm_mul_ss(_a, _b), _c)
#define OZZ_MSUBX(_a, _b, _c) _mm_sub_ss(_mm_mul_ss(_a, _b), _c)
#define OZZ_NMADDX(_a, _b, _c) _mm_sub_ss(_c, _mm_mul_ss(_a, _b))
#define OZZ_NMSUBX(_a, _b, _c) (-_mm_add_ss(_mm_mul_ss(_a, _b), _c))

inline SimdFloat4 DivX(_SimdFloat4 _a, _SimdFloat4 _b) {
    return _mm_div_ss(_a, _b);
}

#define OZZ_SSE_SELECT_F(_b, _true, _false) \
  _mm_blendv_ps(_false, _true, _mm_castsi128_ps(_b))

#define OZZ_SSE_SELECT_I(_b, _true, _false) _mm_blendv_epi8(_false, _true, _b)

@implementation OZZFloat4 {

}

+ (SimdFloat4)zero {
    return _mm_setzero_ps();
}

+ (SimdFloat4)one {
    const __m128i zero = _mm_setzero_si128();
    return _mm_castsi128_ps(
            _mm_srli_epi32(_mm_slli_epi32(_mm_cmpeq_epi32(zero, zero), 25), 2));
}

+ (SimdFloat4)x_axis {
    const __m128i zero = _mm_setzero_si128();
    const __m128i one =
            _mm_srli_epi32(_mm_slli_epi32(_mm_cmpeq_epi32(zero, zero), 25), 2);
    return _mm_castsi128_ps(_mm_srli_si128(one, 12));
}

+ (SimdFloat4)y_axis {
    const __m128i zero = _mm_setzero_si128();
    const __m128i one =
            _mm_srli_epi32(_mm_slli_epi32(_mm_cmpeq_epi32(zero, zero), 25), 2);
    return _mm_castsi128_ps(_mm_slli_si128(_mm_srli_si128(one, 12), 4));
}

+ (SimdFloat4)z_axis {
    const __m128i zero = _mm_setzero_si128();
    const __m128i one =
            _mm_srli_epi32(_mm_slli_epi32(_mm_cmpeq_epi32(zero, zero), 25), 2);
    return _mm_castsi128_ps(_mm_slli_si128(_mm_srli_si128(one, 12), 8));
}

+ (SimdFloat4)w_axis {
    const __m128i zero = _mm_setzero_si128();
    const __m128i one =
            _mm_srli_epi32(_mm_slli_epi32(_mm_cmpeq_epi32(zero, zero), 25), 2);
    return _mm_castsi128_ps(_mm_slli_si128(one, 12));
}

+ (SimdFloat4)LoadWith:(float)_x :(float)_y :(float)_z :(float)_w {
    return _mm_set_ps(_w, _z, _y, _x);
}

+ (SimdFloat4)LoadXWith:(float)_x {
    return _mm_set_ss(_x);
}

+ (SimdFloat4)Load1With:(float)_x {
    return _mm_set_ps1(_x);
}

+ (SimdFloat4)LoadPtrWith:(const float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0xf) && "Invalid alignment");
    return _mm_load_ps(_f);
}

+ (SimdFloat4)LoadPtrUWith:(const float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0x3) && "Invalid alignment");
    return _mm_loadu_ps(_f);
}

+ (SimdFloat4)LoadXPtrUWith:(const float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0x3) && "Invalid alignment");
    return _mm_load_ss(_f);
}

+ (SimdFloat4)Load1PtrUWith:(const float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0x3) && "Invalid alignment");
    return _mm_load_ps1(_f);
}

+ (SimdFloat4)Load2PtrUWith:(const float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0x3) && "Invalid alignment");
    return _mm_unpacklo_ps(_mm_load_ss(_f + 0), _mm_load_ss(_f + 1));
}

+ (SimdFloat4)Load3PtrUWith:(const float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0x3) && "Invalid alignment");
    return _mm_movelh_ps(
            _mm_unpacklo_ps(_mm_load_ss(_f + 0), _mm_load_ss(_f + 1)),
            _mm_load_ss(_f + 2));
}

+ (SimdFloat4)FromIntWith:(_SimdInt4)_i {
    return _mm_cvtepi32_ps(_i);
}

+ (float)GetXWith:(_SimdFloat4)_v {
    return _mm_cvtss_f32(_v);
}

+ (float)GetYWith:(_SimdFloat4)_v {
    return _mm_cvtss_f32(OZZ_SSE_SPLAT_F(_v, 1));
}

+ (float)GetZWith:(_SimdFloat4)_v {
    return _mm_cvtss_f32(_mm_movehl_ps(_v, _v));
}

+ (float)GetWWith:(_SimdFloat4)_v {
    return _mm_cvtss_f32(OZZ_SSE_SPLAT_F(_v, 3));
}

+ (SimdFloat4)SetXWith:(_SimdFloat4)_v :(_SimdFloat4)_f {
    return _mm_move_ss(_v, _f);
}

+ (SimdFloat4)SetYWith:(_SimdFloat4)_v :(_SimdFloat4)_f {
    const __m128 xfnn = _mm_unpacklo_ps(_v, _f);
    return _mm_shuffle_ps(xfnn, _v, _MM_SHUFFLE(3, 2, 1, 0));
}

+ (SimdFloat4)SetZWith:(_SimdFloat4)_v :(_SimdFloat4)_f {
    const __m128 ffww = _mm_shuffle_ps(_f, _v, _MM_SHUFFLE(3, 3, 0, 0));
    return _mm_shuffle_ps(_v, ffww, _MM_SHUFFLE(2, 0, 1, 0));
}

+ (SimdFloat4)SetWWith:(_SimdFloat4)_v :(_SimdFloat4)_f {
    const __m128 ffzz = _mm_shuffle_ps(_f, _v, _MM_SHUFFLE(2, 2, 0, 0));
    return _mm_shuffle_ps(_v, ffzz, _MM_SHUFFLE(0, 2, 1, 0));
}

+ (SimdFloat4)SetIWith:(_SimdFloat4)_v :(_SimdFloat4)_f :(int)_ith {
    assert(_ith >= 0 && _ith <= 3 && "Invalid index, out of range.");
    union {
        SimdFloat4 ret;
        float af[4];
    } u = {_v};
    u.af[_ith] = _mm_cvtss_f32(_f);
    return u.ret;
}

+ (void)StorePtrWith:(_SimdFloat4)_v :(float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0xf) && "Invalid alignment");
    _mm_store_ps(_f, _v);
}

+ (void)Store1PtrWith:(_SimdFloat4)_v :(float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0xf) && "Invalid alignment");
    _mm_store_ss(_f, _v);
}

+ (void)Store2PtrWith:(_SimdFloat4)_v :(float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0xf) && "Invalid alignment");
    _mm_storel_pi(reinterpret_cast<__m64 *>(_f), _v);
}

+ (void)Store3PtrWith:(_SimdFloat4)_v :(float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0xf) && "Invalid alignment");
    _mm_storel_pi(reinterpret_cast<__m64 *>(_f), _v);
    _mm_store_ss(_f + 2, _mm_movehl_ps(_v, _v));
}

+ (void)StorePtrUWith:(_SimdFloat4)_v :(float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0x3) && "Invalid alignment");
    _mm_storeu_ps(_f, _v);
}

+ (void)Store1PtrUWith:(_SimdFloat4)_v :(float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0x3) && "Invalid alignment");
    _mm_store_ss(_f, _v);
}

+ (void)Store2PtrUWith:(_SimdFloat4)_v :(float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0x3) && "Invalid alignment");
    _mm_store_ss(_f + 0, _v);
    _mm_store_ss(_f + 1, OZZ_SSE_SPLAT_F(_v, 1));
}

+ (void)Store3PtrUWith:(_SimdFloat4)_v :(float *)_f {
    assert(!(reinterpret_cast<uintptr_t>(_f) & 0x3) && "Invalid alignment");
    _mm_store_ss(_f + 0, _v);
    _mm_store_ss(_f + 1, OZZ_SSE_SPLAT_F(_v, 1));
    _mm_store_ss(_f + 2, _mm_movehl_ps(_v, _v));
}

+ (SimdFloat4)SplatXWith:(_SimdFloat4)_v {
    return OZZ_SSE_SPLAT_F(_v, 0);
}

+ (SimdFloat4)SplatYWith:(_SimdFloat4)_v {
    return OZZ_SSE_SPLAT_F(_v, 1);
}

+ (SimdFloat4)SplatZWith:(_SimdFloat4)_v {
    return OZZ_SSE_SPLAT_F(_v, 2);
}

+ (SimdFloat4)SplatWWith:(_SimdFloat4)_v {
    return OZZ_SSE_SPLAT_F(_v, 3);
}

+ (SimdFloat4)Swizzle0123With:(_SimdFloat4)_v {
    return _v;
}

+ (SimdFloat4)Swizzle0101With:(_SimdFloat4)_v {
    return _mm_movelh_ps(_v, _v);
}

+ (SimdFloat4)Swizzle2323With:(_SimdFloat4)_v {
    return _mm_movehl_ps(_v, _v);
}

+ (SimdFloat4)Swizzle0011With:(_SimdFloat4)_v {
    return _mm_unpacklo_ps(_v, _v);
}

+ (SimdFloat4)Swizzle2233With:(_SimdFloat4)_v {
    return _mm_unpackhi_ps(_v, _v);
}

+ (void)Transpose4x1With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out {
    const __m128 xz = _mm_unpacklo_ps(_in[0], _in[2]);
    const __m128 yw = _mm_unpacklo_ps(_in[1], _in[3]);
    _out[0] = _mm_unpacklo_ps(xz, yw);
}

+ (void)Transpose1x4With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out {
    const __m128 zwzw = _mm_movehl_ps(_in[0], _in[0]);
    const __m128 yyyy = OZZ_SSE_SPLAT_F(_in[0], 1);
    const __m128 wwww = OZZ_SSE_SPLAT_F(_in[0], 3);
    const __m128 zero = _mm_setzero_ps();
    _out[0] = _mm_move_ss(zero, _in[0]);
    _out[1] = _mm_move_ss(zero, yyyy);
    _out[2] = _mm_move_ss(zero, zwzw);
    _out[3] = _mm_move_ss(zero, wwww);
}

+ (void)Transpose4x2With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out {
    const __m128 tmp0 = _mm_unpacklo_ps(_in[0], _in[2]);
    const __m128 tmp1 = _mm_unpacklo_ps(_in[1], _in[3]);
    _out[0] = _mm_unpacklo_ps(tmp0, tmp1);
    _out[1] = _mm_unpackhi_ps(tmp0, tmp1);
}

+ (void)Transpose2x4With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out {
    const __m128 tmp0 = _mm_unpacklo_ps(_in[0], _in[1]);
    const __m128 tmp1 = _mm_unpackhi_ps(_in[0], _in[1]);
    const __m128 zero = _mm_setzero_ps();
    _out[0] = _mm_movelh_ps(tmp0, zero);
    _out[1] = _mm_movehl_ps(zero, tmp0);
    _out[2] = _mm_movelh_ps(tmp1, zero);
    _out[3] = _mm_movehl_ps(zero, tmp1);
}

+ (void)Transpose4x3With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out {
    const __m128 tmp0 = _mm_unpacklo_ps(_in[0], _in[2]);
    const __m128 tmp1 = _mm_unpacklo_ps(_in[1], _in[3]);
    const __m128 tmp2 = _mm_unpackhi_ps(_in[0], _in[2]);
    const __m128 tmp3 = _mm_unpackhi_ps(_in[1], _in[3]);
    _out[0] = _mm_unpacklo_ps(tmp0, tmp1);
    _out[1] = _mm_unpackhi_ps(tmp0, tmp1);
    _out[2] = _mm_unpacklo_ps(tmp2, tmp3);
}

+ (void)Transpose3x4With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out {
    const __m128 zero = _mm_setzero_ps();
    const __m128 temp0 = _mm_unpacklo_ps(_in[0], _in[1]);
    const __m128 temp1 = _mm_unpacklo_ps(_in[2], zero);
    const __m128 temp2 = _mm_unpackhi_ps(_in[0], _in[1]);
    const __m128 temp3 = _mm_unpackhi_ps(_in[2], zero);
    _out[0] = _mm_movelh_ps(temp0, temp1);
    _out[1] = _mm_movehl_ps(temp1, temp0);
    _out[2] = _mm_movelh_ps(temp2, temp3);
    _out[3] = _mm_movehl_ps(temp3, temp2);
}

+ (void)Transpose4x4With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out {
    const __m128 tmp0 = _mm_unpacklo_ps(_in[0], _in[2]);
    const __m128 tmp1 = _mm_unpacklo_ps(_in[1], _in[3]);
    const __m128 tmp2 = _mm_unpackhi_ps(_in[0], _in[2]);
    const __m128 tmp3 = _mm_unpackhi_ps(_in[1], _in[3]);
    _out[0] = _mm_unpacklo_ps(tmp0, tmp1);
    _out[1] = _mm_unpackhi_ps(tmp0, tmp1);
    _out[2] = _mm_unpacklo_ps(tmp2, tmp3);
    _out[3] = _mm_unpackhi_ps(tmp2, tmp3);
}

+ (void)Transpose16x16With:(const SimdFloat4 *)_in :(SimdFloat4 *)_out {
    const __m128 tmp0 = _mm_unpacklo_ps(_in[0], _in[2]);
    const __m128 tmp1 = _mm_unpacklo_ps(_in[1], _in[3]);
    _out[0] = _mm_unpacklo_ps(tmp0, tmp1);
    _out[4] = _mm_unpackhi_ps(tmp0, tmp1);
    const __m128 tmp2 = _mm_unpackhi_ps(_in[0], _in[2]);
    const __m128 tmp3 = _mm_unpackhi_ps(_in[1], _in[3]);
    _out[8] = _mm_unpacklo_ps(tmp2, tmp3);
    _out[12] = _mm_unpackhi_ps(tmp2, tmp3);
    const __m128 tmp4 = _mm_unpacklo_ps(_in[4], _in[6]);
    const __m128 tmp5 = _mm_unpacklo_ps(_in[5], _in[7]);
    _out[1] = _mm_unpacklo_ps(tmp4, tmp5);
    _out[5] = _mm_unpackhi_ps(tmp4, tmp5);
    const __m128 tmp6 = _mm_unpackhi_ps(_in[4], _in[6]);
    const __m128 tmp7 = _mm_unpackhi_ps(_in[5], _in[7]);
    _out[9] = _mm_unpacklo_ps(tmp6, tmp7);
    _out[13] = _mm_unpackhi_ps(tmp6, tmp7);
    const __m128 tmp8 = _mm_unpacklo_ps(_in[8], _in[10]);
    const __m128 tmp9 = _mm_unpacklo_ps(_in[9], _in[11]);
    _out[2] = _mm_unpacklo_ps(tmp8, tmp9);
    _out[6] = _mm_unpackhi_ps(tmp8, tmp9);
    const __m128 tmp10 = _mm_unpackhi_ps(_in[8], _in[10]);
    const __m128 tmp11 = _mm_unpackhi_ps(_in[9], _in[11]);
    _out[10] = _mm_unpacklo_ps(tmp10, tmp11);
    _out[14] = _mm_unpackhi_ps(tmp10, tmp11);
    const __m128 tmp12 = _mm_unpacklo_ps(_in[12], _in[14]);
    const __m128 tmp13 = _mm_unpacklo_ps(_in[13], _in[15]);
    _out[3] = _mm_unpacklo_ps(tmp12, tmp13);
    _out[7] = _mm_unpackhi_ps(tmp12, tmp13);
    const __m128 tmp14 = _mm_unpackhi_ps(_in[12], _in[14]);
    const __m128 tmp15 = _mm_unpackhi_ps(_in[13], _in[15]);
    _out[11] = _mm_unpacklo_ps(tmp14, tmp15);
    _out[15] = _mm_unpackhi_ps(tmp14, tmp15);
}

+ (SimdFloat4)MAddWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c {
    return OZZ_MADD(_a, _b, _c);
}

+ (SimdFloat4)MSubWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c {
    return OZZ_MSUB(_a, _b, _c);
}

+ (SimdFloat4)NMAddWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c {
    return OZZ_NMADD(_a, _b, _c);
}

+ (SimdFloat4)NMSubWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_c {
    return OZZ_NMSUB(_a, _b, _c);
}

+ (SimdFloat4)DivXWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return _mm_div_ss(_a, _b);
}

+ (SimdFloat4)HAdd2With:(_SimdFloat4)_v {
    return OZZ_SSE_HADD2_F(_v);
}

+ (SimdFloat4)HAdd3With:(_SimdFloat4)_v {
    return OZZ_SSE_HADD3_F(_v);
}

+ (SimdFloat4)HAdd4With:(_SimdFloat4)_v {
    __m128 hadd4;
    OZZ_SSE_HADD4_F(_v, hadd4);
    return hadd4;
}

+ (SimdFloat4)Dot2With:(_SimdFloat4)_a :(_SimdFloat4)_b {
    __m128 dot2;
    OZZ_SSE_DOT2_F(_a, _b, dot2);
    return dot2;
}

+ (SimdFloat4)Dot3With:(_SimdFloat4)_a :(_SimdFloat4)_b {
    __m128 dot3;
    OZZ_SSE_DOT3_F(_a, _b, dot3);
    return dot3;
}

+ (SimdFloat4)Dot4With:(_SimdFloat4)_a :(_SimdFloat4)_b {
    __m128 dot4;
    OZZ_SSE_DOT4_F(_a, _b, dot4);
    return dot4;
}

+ (SimdFloat4)Cross3With:(_SimdFloat4)_a :(_SimdFloat4)_b {
    // Implementation with 3 shuffles only is based on:
    // https://geometrian.com/programming/tutorials/cross-product
    const __m128 shufa = OZZ_SHUFFLE_PS1(_a, _MM_SHUFFLE(3, 0, 2, 1));
    const __m128 shufb = OZZ_SHUFFLE_PS1(_b, _MM_SHUFFLE(3, 0, 2, 1));
    const __m128 shufc = OZZ_MSUB(_a, shufb, _mm_mul_ps(_b, shufa));
    return OZZ_SHUFFLE_PS1(shufc, _MM_SHUFFLE(3, 0, 2, 1));
}

+ (SimdFloat4)RcpEstWith:(_SimdFloat4)_v {
    return _mm_rcp_ps(_v);
}

+ (SimdFloat4)RcpEstNRWith:(_SimdFloat4)_v {
    const __m128 nr = _mm_rcp_ps(_v);
    // Do one more Newton-Raphson step to improve precision.
    return OZZ_NMADD(_mm_mul_ps(nr, nr), _v, _mm_add_ps(nr, nr));
}

+ (SimdFloat4)RcpEstXWith:(_SimdFloat4)_v {
    return _mm_rcp_ss(_v);
}

+ (SimdFloat4)RcpEstXNRWith:(_SimdFloat4)_v {
    const __m128 nr = _mm_rcp_ss(_v);
    // Do one more Newton-Raphson step to improve precision.
    return OZZ_NMADDX(_mm_mul_ss(nr, nr), _v, _mm_add_ss(nr, nr));
}

+ (SimdFloat4)SqrtWith:(_SimdFloat4)_v {
    return _mm_sqrt_ps(_v);
}

+ (SimdFloat4)SqrtXWith:(_SimdFloat4)_v {
    return _mm_sqrt_ss(_v);
}

+ (SimdFloat4)RSqrtEstWith:(_SimdFloat4)_v {
    return _mm_rsqrt_ps(_v);
}

+ (SimdFloat4)RSqrtEstNRWith:(_SimdFloat4)_v {
    const __m128 nr = _mm_rsqrt_ps(_v);
    // Do one more Newton-Raphson step to improve precision.
    return _mm_mul_ps(_mm_mul_ps(_mm_set_ps1(.5f), nr),
            OZZ_NMADD(_mm_mul_ps(_v, nr), nr, _mm_set_ps1(3.f)));
}

+ (SimdFloat4)RSqrtEstXWith:(_SimdFloat4)_v {
    return _mm_rsqrt_ss(_v);
}

+ (SimdFloat4)RSqrtEstXNRWith:(_SimdFloat4)_v {
    const __m128 nr = _mm_rsqrt_ss(_v);
    // Do one more Newton-Raphson step to improve precision.
    return _mm_mul_ss(_mm_mul_ss(_mm_set_ps1(.5f), nr),
            OZZ_NMADDX(_mm_mul_ss(_v, nr), nr, _mm_set_ps1(3.f)));
}

+ (SimdFloat4)AbsWith:(_SimdFloat4)_v {
    const __m128i zero = _mm_setzero_si128();
    return _mm_and_ps(
            _mm_castsi128_ps(_mm_srli_epi32(_mm_cmpeq_epi32(zero, zero), 1)), _v);
}

+ (SimdInt4)SignWith:(_SimdFloat4)_v {
    return _mm_slli_epi32(_mm_srli_epi32(_mm_castps_si128(_v), 31), 31);
}

+ (SimdFloat4)Length2With:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT2_F(_v, _v, sq_len);
    return _mm_sqrt_ss(sq_len);
}

+ (SimdFloat4)Length3With:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT3_F(_v, _v, sq_len);
    return _mm_sqrt_ss(sq_len);
}

+ (SimdFloat4)Length4With:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT4_F(_v, _v, sq_len);
    return _mm_sqrt_ss(sq_len);
}

+ (SimdFloat4)Length2SqrWith:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT2_F(_v, _v, sq_len);
    return sq_len;
}

+ (SimdFloat4)Length3SqrWith:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT3_F(_v, _v, sq_len);
    return sq_len;
}

+ (SimdFloat4)Length4SqrWith:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT4_F(_v, _v, sq_len);
    return sq_len;
}

+ (SimdFloat4)Normalize2With:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT2_F(_v, _v, sq_len);
    assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
    const __m128 inv_len = _mm_div_ss([OZZFloat4 one], _mm_sqrt_ss(sq_len));
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128 norm = _mm_mul_ps(_v, inv_lenxxxx);
    return _mm_movelh_ps(norm, _mm_movehl_ps(_v, _v));
}

+ (SimdFloat4)Normalize3With:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT3_F(_v, _v, sq_len);
    assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
    const __m128 inv_len = _mm_div_ss([OZZFloat4 one], _mm_sqrt_ss(sq_len));
    const __m128 vwxyz = OZZ_SHUFFLE_PS1(_v, _MM_SHUFFLE(0, 1, 2, 3));
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128 normwxyz = _mm_move_ss(_mm_mul_ps(vwxyz, inv_lenxxxx), vwxyz);
    return OZZ_SHUFFLE_PS1(normwxyz, _MM_SHUFFLE(0, 1, 2, 3));
}

+ (SimdFloat4)Normalize4With:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT4_F(_v, _v, sq_len);
    assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
    const __m128 inv_len = _mm_div_ss([OZZFloat4 one], _mm_sqrt_ss(sq_len));
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    return _mm_mul_ps(_v, inv_lenxxxx);
}

+ (SimdFloat4)NormalizeEst2With:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT2_F(_v, _v, sq_len);
    assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
    const __m128 inv_len = _mm_rsqrt_ss(sq_len);
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128 norm = _mm_mul_ps(_v, inv_lenxxxx);
    return _mm_movelh_ps(norm, _mm_movehl_ps(_v, _v));
}

+ (SimdFloat4)NormalizeEst3With:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT3_F(_v, _v, sq_len);
    assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
    const __m128 inv_len = _mm_rsqrt_ss(sq_len);
    const __m128 vwxyz = OZZ_SHUFFLE_PS1(_v, _MM_SHUFFLE(0, 1, 2, 3));
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128 normwxyz = _mm_move_ss(_mm_mul_ps(vwxyz, inv_lenxxxx), vwxyz);
    return OZZ_SHUFFLE_PS1(normwxyz, _MM_SHUFFLE(0, 1, 2, 3));
}

+ (SimdFloat4)NormalizeEst4With:(_SimdFloat4)_v {
    __m128 sq_len;
    OZZ_SSE_DOT4_F(_v, _v, sq_len);
    assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
    const __m128 inv_len = _mm_rsqrt_ss(sq_len);
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    return _mm_mul_ps(_v, inv_lenxxxx);
}

+ (SimdInt4)IsNormalized2With:(_SimdFloat4)_v {
    const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceSq);
    const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceSq);
    __m128 dot;
    OZZ_SSE_DOT2_F(_v, _v, dot);
    __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
    return _mm_castps_si128(
            _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4)IsNormalized3With:(_SimdFloat4)_v {
    const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceSq);
    const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceSq);
    __m128 dot;
    OZZ_SSE_DOT3_F(_v, _v, dot);
    __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
    return _mm_castps_si128(
            _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4)IsNormalized4With:(_SimdFloat4)_v {
    const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceSq);
    const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceSq);
    __m128 dot;
    OZZ_SSE_DOT4_F(_v, _v, dot);
    __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
    return _mm_castps_si128(
            _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4)IsNormalizedEst2With:(_SimdFloat4)_v {
    const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceEstSq);
    const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceEstSq);
    __m128 dot;
    OZZ_SSE_DOT2_F(_v, _v, dot);
    __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
    return _mm_castps_si128(
            _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4)IsNormalizedEst3With:(_SimdFloat4)_v {
    const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceEstSq);
    const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceEstSq);
    __m128 dot;
    OZZ_SSE_DOT3_F(_v, _v, dot);
    __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
    return _mm_castps_si128(
            _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4)IsNormalizedEst4With:(_SimdFloat4)_v {
    const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceEstSq);
    const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceEstSq);
    __m128 dot;
    OZZ_SSE_DOT4_F(_v, _v, dot);
    __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
    return _mm_castps_si128(
            _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdFloat4)NormalizeSafe2With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    // assert(AreAllTrue1(IsNormalized2(_safe)) && "_safe is not normalized");
    __m128 sq_len;
    OZZ_SSE_DOT2_F(_v, _v, sq_len);
    const __m128 inv_len = _mm_div_ss([OZZFloat4 one], _mm_sqrt_ss(sq_len));
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128 norm = _mm_mul_ps(_v, inv_lenxxxx);
    const __m128i cond = _mm_castps_si128(
            _mm_cmple_ps(OZZ_SSE_SPLAT_F(sq_len, 0), _mm_setzero_ps()));
    const __m128 cfalse = _mm_movelh_ps(norm, _mm_movehl_ps(_v, _v));
    return OZZ_SSE_SELECT_F(cond, _safe, cfalse);
}

+ (SimdFloat4)NormalizeSafe3With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    // assert(AreAllTrue1(IsNormalized3(_safe)) && "_safe is not normalized");
    __m128 sq_len;
    OZZ_SSE_DOT3_F(_v, _v, sq_len);
    const __m128 inv_len = _mm_div_ss([OZZFloat4 one], _mm_sqrt_ss(sq_len));
    const __m128 vwxyz = OZZ_SHUFFLE_PS1(_v, _MM_SHUFFLE(0, 1, 2, 3));
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128 normwxyz = _mm_move_ss(_mm_mul_ps(vwxyz, inv_lenxxxx), vwxyz);
    const __m128i cond = _mm_castps_si128(
            _mm_cmple_ps(OZZ_SSE_SPLAT_F(sq_len, 0), _mm_setzero_ps()));
    const __m128 cfalse = OZZ_SHUFFLE_PS1(normwxyz, _MM_SHUFFLE(0, 1, 2, 3));
    return OZZ_SSE_SELECT_F(cond, _safe, cfalse);
}

+ (SimdFloat4)NormalizeSafe4With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    // assert(AreAllTrue1(IsNormalized4(_safe)) && "_safe is not normalized");
    __m128 sq_len;
    OZZ_SSE_DOT4_F(_v, _v, sq_len);
    const __m128 inv_len = _mm_div_ss([OZZFloat4 one], _mm_sqrt_ss(sq_len));
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128i cond = _mm_castps_si128(
            _mm_cmple_ps(OZZ_SSE_SPLAT_F(sq_len, 0), _mm_setzero_ps()));
    const __m128 cfalse = _mm_mul_ps(_v, inv_lenxxxx);
    return OZZ_SSE_SELECT_F(cond, _safe, cfalse);
}

+ (SimdFloat4)NormalizeSafeEst2With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    // assert(AreAllTrue1(IsNormalizedEst2(_safe)) && "_safe is not normalized");
    __m128 sq_len;
    OZZ_SSE_DOT2_F(_v, _v, sq_len);
    const __m128 inv_len = _mm_rsqrt_ss(sq_len);
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128 norm = _mm_mul_ps(_v, inv_lenxxxx);
    const __m128i cond = _mm_castps_si128(
            _mm_cmple_ps(OZZ_SSE_SPLAT_F(sq_len, 0), _mm_setzero_ps()));
    const __m128 cfalse = _mm_movelh_ps(norm, _mm_movehl_ps(_v, _v));
    return OZZ_SSE_SELECT_F(cond, _safe, cfalse);
}

+ (SimdFloat4)NormalizeSafeEst3With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    // assert(AreAllTrue1(IsNormalizedEst3(_safe)) && "_safe is not normalized");
    __m128 sq_len;
    OZZ_SSE_DOT3_F(_v, _v, sq_len);
    const __m128 inv_len = _mm_rsqrt_ss(sq_len);
    const __m128 vwxyz = OZZ_SHUFFLE_PS1(_v, _MM_SHUFFLE(0, 1, 2, 3));
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128 normwxyz = _mm_move_ss(_mm_mul_ps(vwxyz, inv_lenxxxx), vwxyz);
    const __m128i cond = _mm_castps_si128(
            _mm_cmple_ps(OZZ_SSE_SPLAT_F(sq_len, 0), _mm_setzero_ps()));
    const __m128 cfalse = OZZ_SHUFFLE_PS1(normwxyz, _MM_SHUFFLE(0, 1, 2, 3));
    return OZZ_SSE_SELECT_F(cond, _safe, cfalse);
}

+ (SimdFloat4)NormalizeSafeEst4With:(_SimdFloat4)_v :(_SimdFloat4)_safe {
    // assert(AreAllTrue1(IsNormalizedEst4(_safe)) && "_safe is not normalized");
    __m128 sq_len;
    OZZ_SSE_DOT4_F(_v, _v, sq_len);
    const __m128 inv_len = _mm_rsqrt_ss(sq_len);
    const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
    const __m128i cond = _mm_castps_si128(
            _mm_cmple_ps(OZZ_SSE_SPLAT_F(sq_len, 0), _mm_setzero_ps()));
    const __m128 cfalse = _mm_mul_ps(_v, inv_lenxxxx);
    return OZZ_SSE_SELECT_F(cond, _safe, cfalse);
}

+ (SimdFloat4)LerpWith:(_SimdFloat4)_a :(_SimdFloat4)_b :(_SimdFloat4)_alpha {
    return OZZ_MADD(_alpha, _mm_sub_ps(_b, _a), _a);
}

+ (SimdFloat4)MinWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return _mm_min_ps(_a, _b);
}

+ (SimdFloat4)MaxWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return _mm_max_ps(_a, _b);
}

+ (SimdFloat4)Min0With:(_SimdFloat4)_v {
    return _mm_min_ps(_mm_setzero_ps(), _v);
}

+ (SimdFloat4)Max0With:(_SimdFloat4)_v {
    return _mm_max_ps(_mm_setzero_ps(), _v);
}

+ (SimdFloat4)ClampWith:(_SimdFloat4)_a :(_SimdFloat4)_v :(_SimdFloat4)_b {
    return _mm_max_ps(_a, _mm_min_ps(_v, _b));
}

+ (SimdFloat4)SelectWith:(_SimdInt4)_b :(_SimdFloat4)_true :(_SimdFloat4)_false {
    return OZZ_SSE_SELECT_F(_b, _true, _false);
}

+ (SimdInt4)CmpEqWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return _mm_castps_si128(_mm_cmpeq_ps(_a, _b));
}

+ (SimdInt4)CmpNeWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return _mm_castps_si128(_mm_cmpneq_ps(_a, _b));
}

+ (SimdInt4)CmpLtWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return _mm_castps_si128(_mm_cmplt_ps(_a, _b));
}

+ (SimdInt4)CmpLeWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return _mm_castps_si128(_mm_cmple_ps(_a, _b));
}

+ (SimdInt4)CmpGtWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return _mm_castps_si128(_mm_cmpgt_ps(_a, _b));
}

+ (SimdInt4)CmpGeWith:(_SimdFloat4)_a :(_SimdFloat4)_b {
    return _mm_castps_si128(_mm_cmpge_ps(_a, _b));
}

+ (SimdFloat4)AndWith:(_SimdFloat4)_a float4:(_SimdFloat4)_b {
    return _mm_and_ps(_a, _b);
}

+ (SimdFloat4)OrWith:(_SimdFloat4)_a float4:(_SimdFloat4)_b {
    return _mm_or_ps(_a, _b);
}

+ (SimdFloat4)XorWith:(_SimdFloat4)_a float4:(_SimdFloat4)_b {
    return _mm_xor_ps(_a, _b);
}

+ (SimdFloat4)AndWith:(_SimdFloat4)_a int4:(_SimdInt4)_b {
    return _mm_and_ps(_a, _mm_castsi128_ps(_b));
}

+ (SimdFloat4)AndNotWith:(_SimdFloat4)_a :(_SimdInt4)_b {
    return _mm_andnot_ps(_mm_castsi128_ps(_b), _a);
}

+ (SimdFloat4)OrWith:(_SimdFloat4)_a int4:(_SimdInt4)_b {
    return _mm_or_ps(_a, _mm_castsi128_ps(_b));
}

+ (SimdFloat4)XorWith:(_SimdFloat4)_a int4:(_SimdInt4)_b {
    return _mm_xor_ps(_a, _mm_castsi128_ps(_b));
}

+ (SimdFloat4)CosWith:(_SimdFloat4)_v {
    return _mm_set_ps(std::cos([OZZFloat4 GetWWith:_v]), std::cos([OZZFloat4 GetZWith:_v]),
            std::cos([OZZFloat4 GetYWith:_v]), std::cos([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4)CosXWith:(_SimdFloat4)_v {
    return _mm_move_ss(_v, _mm_set_ps1(std::cos([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4)ACosWith:(_SimdFloat4)_v {
    return _mm_set_ps(std::acos([OZZFloat4 GetWWith:_v]), std::acos([OZZFloat4 GetZWith:_v]),
            std::acos([OZZFloat4 GetYWith:_v]), std::acos([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4)ACosXWith:(_SimdFloat4)_v {
    return _mm_move_ss(_v, _mm_set_ps1(std::acos([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4)SinWith:(_SimdFloat4)_v {
    return _mm_set_ps(std::sin([OZZFloat4 GetWWith:_v]), std::sin([OZZFloat4 GetZWith:_v]), std::sin([OZZFloat4 GetYWith:_v]),
            std::sin([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4)SinXWith:(_SimdFloat4)_v {
    return _mm_move_ss(_v, _mm_set_ps1(std::sin([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4)ASinWith:(_SimdFloat4)_v {
    return _mm_set_ps(std::asin([OZZFloat4 GetWWith:_v]), std::asin([OZZFloat4 GetZWith:_v]),
            std::asin([OZZFloat4 GetYWith:_v]), std::asin([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4)ASinXWith:(_SimdFloat4)_v {
    return _mm_move_ss(_v, _mm_set_ps1(std::asin([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4)TanWith:(_SimdFloat4)_v {
    return _mm_set_ps(std::tan([OZZFloat4 GetWWith:_v]), std::tan([OZZFloat4 GetZWith:_v]),
            std::tan([OZZFloat4 GetYWith:_v]), std::tan([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4)TanXWith:(_SimdFloat4)_v {
    return _mm_move_ss(_v, _mm_set_ps1(std::tan([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4)ATanWith:(_SimdFloat4)_v {
    return _mm_set_ps(std::atan([OZZFloat4 GetWWith:_v]), std::atan([OZZFloat4 GetZWith:_v]),
            std::atan([OZZFloat4 GetYWith:_v]), std::atan([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4)ATanXWith:(_SimdFloat4)_v {
    return _mm_move_ss(_v, _mm_set_ps1(std::atan([OZZFloat4 GetXWith:_v])));
}


@end

//MARK: - OZZInt4
@implementation OZZInt4 {

}

+ (SimdInt4)zero {
    return _mm_setzero_si128();
}

+ (SimdInt4)one {
    const __m128i zero = _mm_setzero_si128();
    return _mm_sub_epi32(zero, _mm_cmpeq_epi32(zero, zero));
}

+ (SimdInt4)x_axis {
    const __m128i zero = _mm_setzero_si128();
    return _mm_srli_si128(_mm_sub_epi32(zero, _mm_cmpeq_epi32(zero, zero)), 12);
}

+ (SimdInt4)y_axis {
    const __m128i zero = _mm_setzero_si128();
    return _mm_slli_si128(
            _mm_srli_si128(_mm_sub_epi32(zero, _mm_cmpeq_epi32(zero, zero)), 12), 4);
}

+ (SimdInt4)z_axis {
    const __m128i zero = _mm_setzero_si128();
    return _mm_slli_si128(
            _mm_srli_si128(_mm_sub_epi32(zero, _mm_cmpeq_epi32(zero, zero)), 12), 8);
}

+ (SimdInt4)w_axis {
    const __m128i zero = _mm_setzero_si128();
    return _mm_slli_si128(_mm_sub_epi32(zero, _mm_cmpeq_epi32(zero, zero)), 12);
}

+ (SimdInt4)all_true {
    const __m128i zero = _mm_setzero_si128();
    return _mm_cmpeq_epi32(zero, zero);
}

+ (SimdInt4)all_false {
    return _mm_setzero_si128();
}

+ (SimdInt4)mask_sign {
    const __m128i zero = _mm_setzero_si128();
    return _mm_slli_epi32(_mm_cmpeq_epi32(zero, zero), 31);
}

+ (SimdInt4)mask_sign_xyz {
    const __m128i zero = _mm_setzero_si128();
    return _mm_srli_si128(_mm_slli_epi32(_mm_cmpeq_epi32(zero, zero), 31), 4);
}

+ (SimdInt4)mask_sign_w {
    const __m128i zero = _mm_setzero_si128();
    return _mm_slli_si128(_mm_slli_epi32(_mm_cmpeq_epi32(zero, zero), 31), 12);
}

+ (SimdInt4)mask_not_sign {
    const __m128i zero = _mm_setzero_si128();
    return _mm_srli_epi32(_mm_cmpeq_epi32(zero, zero), 1);
}

+ (SimdInt4)mask_ffff {
    const __m128i zero = _mm_setzero_si128();
    return _mm_cmpeq_epi32(zero, zero);
}

+ (SimdInt4)mask_0000 {
    return _mm_setzero_si128();
}

+ (SimdInt4)mask_fff0 {
    const __m128i zero = _mm_setzero_si128();
    return _mm_srli_si128(_mm_cmpeq_epi32(zero, zero), 4);
}

+ (SimdInt4)mask_f000 {
    const __m128i zero = _mm_setzero_si128();
    return _mm_srli_si128(_mm_cmpeq_epi32(zero, zero), 12);
}

+ (SimdInt4)mask_0f00 {
    const __m128i zero = _mm_setzero_si128();
    return _mm_srli_si128(_mm_slli_si128(_mm_cmpeq_epi32(zero, zero), 12), 8);
}

+ (SimdInt4)mask_00f0 {
    const __m128i zero = _mm_setzero_si128();
    return _mm_srli_si128(_mm_slli_si128(_mm_cmpeq_epi32(zero, zero), 12), 4);
}

+ (SimdInt4)mask_000f {
    const __m128i zero = _mm_setzero_si128();
    return _mm_slli_si128(_mm_cmpeq_epi32(zero, zero), 12);
}

+ (SimdInt4)LoadWithInt:(int)_x :(int)_y :(int)_z :(int)_w {
    return _mm_set_epi32(_w, _z, _y, _x);
}

+ (SimdInt4)LoadXWithInt:(int)_x {
    return _mm_set_epi32(0, 0, 0, _x);
}

+ (SimdInt4)Load1WithInt:(int)_x {
    return _mm_set1_epi32(_x);
}

+ (SimdInt4)LoadWithBool:(bool)_x :(bool)_y :(bool)_z :(bool)_w {
    return _mm_sub_epi32(_mm_setzero_si128(), _mm_set_epi32(_w, _z, _y, _x));
}

+ (SimdInt4)LoadXWithBool:(bool)_x {
    return _mm_sub_epi32(_mm_setzero_si128(), _mm_set_epi32(0, 0, 0, _x));
}

+ (SimdInt4)Load1WithBool:(bool)_x {
    return _mm_sub_epi32(_mm_setzero_si128(), _mm_set1_epi32(_x));
}

+ (SimdInt4)LoadPtrWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0xf) && "Invalid alignment");
    return _mm_load_si128(reinterpret_cast<const __m128i *>(_i));
}

+ (SimdInt4)LoadXPtrWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0xf) && "Invalid alignment");
    return _mm_cvtsi32_si128(*_i);
}

+ (SimdInt4)Load1PtrWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0xf) && "Invalid alignment");
    return _mm_shuffle_epi32(
            _mm_loadl_epi64(reinterpret_cast<const __m128i *>(_i)),
            _MM_SHUFFLE(0, 0, 0, 0));
}

+ (SimdInt4)Load2PtrWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0xf) && "Invalid alignment");
    return _mm_loadl_epi64(reinterpret_cast<const __m128i *>(_i));
}

+ (SimdInt4)Load3PtrWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0xf) && "Invalid alignment");
    return _mm_set_epi32(0, _i[2], _i[1], _i[0]);
}

+ (SimdInt4)LoadPtrUWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0x3) && "Invalid alignment");
    return _mm_loadu_si128(reinterpret_cast<const __m128i *>(_i));
}

+ (SimdInt4)LoadXPtrUWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0x3) && "Invalid alignment");
    return _mm_cvtsi32_si128(*_i);
}

+ (SimdInt4)Load1PtrUWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0x3) && "Invalid alignment");
    return _mm_set1_epi32(*_i);
}

+ (SimdInt4)Load2PtrUWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0x3) && "Invalid alignment");
    return _mm_set_epi32(0, 0, _i[1], _i[0]);
}

+ (SimdInt4)Load3PtrUWith:(const int *)_i {
    assert(!(uintptr_t(_i) & 0x3) && "Invalid alignment");
    return _mm_set_epi32(0, _i[2], _i[1], _i[0]);
}

+ (SimdInt4)FromFloatRoundWith:(_SimdFloat4)_f {
    return _mm_cvtps_epi32(_f);
}

+ (SimdInt4)FromFloatTruncWith:(_SimdFloat4)_f {
    return _mm_cvttps_epi32(_f);
}

+ (int)GetXWith:(_SimdInt4)_v {
    return _mm_cvtsi128_si32(_v);
}

+ (int)GetYWith:(_SimdInt4)_v {
    return _mm_cvtsi128_si32(OZZ_SSE_SPLAT_I(_v, 1));
}

+ (int)GetZWith:(_SimdInt4)_v {
    return _mm_cvtsi128_si32(_mm_unpackhi_epi32(_v, _v));
}

+ (int)GetWWith:(_SimdInt4)_v {
    return _mm_cvtsi128_si32(OZZ_SSE_SPLAT_I(_v, 3));
}

+ (SimdInt4)SetXWith:(_SimdInt4)_v :(_SimdInt4)_i {
    return _mm_castps_si128(
            _mm_move_ss(_mm_castsi128_ps(_v), _mm_castsi128_ps(_i)));
}

+ (SimdInt4)SetYWith:(_SimdInt4)_v :(_SimdInt4)_i {
    const __m128 xfnn = _mm_castsi128_ps(_mm_unpacklo_epi32(_v, _i));
    return _mm_castps_si128(
            _mm_shuffle_ps(xfnn, _mm_castsi128_ps(_v), _MM_SHUFFLE(3, 2, 1, 0)));
}

+ (SimdInt4)SetZWith:(_SimdInt4)_v :(_SimdInt4)_i {
    const __m128 ffww = _mm_shuffle_ps(_mm_castsi128_ps(_i), _mm_castsi128_ps(_v),
            _MM_SHUFFLE(3, 3, 0, 0));
    return _mm_castps_si128(
            _mm_shuffle_ps(_mm_castsi128_ps(_v), ffww, _MM_SHUFFLE(2, 0, 1, 0)));
}

+ (SimdInt4)SetWWith:(_SimdInt4)_v :(_SimdInt4)_i {
    const __m128 ffzz = _mm_shuffle_ps(_mm_castsi128_ps(_i), _mm_castsi128_ps(_v),
            _MM_SHUFFLE(2, 2, 0, 0));
    return _mm_castps_si128(
            _mm_shuffle_ps(_mm_castsi128_ps(_v), ffzz, _MM_SHUFFLE(0, 2, 1, 0)));
}

+ (SimdInt4)SetIWith:(_SimdInt4)_v :(_SimdInt4)_i :(int)_ith {
    assert(_ith >= 0 && _ith <= 3 && "Invalid index, out of range.");
    union {
        SimdInt4 ret;
        int af[4];
    } u = {_v};
    u.af[_ith] = [OZZInt4 GetXWith:_i];
    return u.ret;
}

+ (void)StorePtrWith:(_SimdInt4)_v :(int *)_i {
    assert(!(uintptr_t(_i) & 0xf) && "Invalid alignment");
    _mm_store_si128(reinterpret_cast<__m128i *>(_i), _v);
}

+ (void)Store1PtrWith:(_SimdInt4)_v :(int *)_i {
    assert(!(uintptr_t(_i) & 0xf) && "Invalid alignment");
    *_i = _mm_cvtsi128_si32(_v);
}

+ (void)Store2PtrWith:(_SimdInt4)_v :(int *)_i {
    assert(!(uintptr_t(_i) & 0xf) && "Invalid alignment");
    _i[0] = _mm_cvtsi128_si32(_v);
    _i[1] = _mm_cvtsi128_si32(OZZ_SSE_SPLAT_I(_v, 1));
}

+ (void)Store3PtrWith:(_SimdInt4)_v :(int *)_i {
    assert(!(uintptr_t(_i) & 0xf) && "Invalid alignment");
    _i[0] = _mm_cvtsi128_si32(_v);
    _i[1] = _mm_cvtsi128_si32(OZZ_SSE_SPLAT_I(_v, 1));
    _i[2] = _mm_cvtsi128_si32(_mm_unpackhi_epi32(_v, _v));
}

+ (void)StorePtrUWith:(_SimdInt4)_v :(int *)_i {
    assert(!(uintptr_t(_i) & 0x3) && "Invalid alignment");
    _mm_storeu_si128(reinterpret_cast<__m128i *>(_i), _v);
}

+ (void)Store1PtrUWith:(_SimdInt4)_v :(int *)_i {
    assert(!(uintptr_t(_i) & 0x3) && "Invalid alignment");
    *_i = _mm_cvtsi128_si32(_v);
}

+ (void)Store2PtrUWith:(_SimdInt4)_v :(int *)_i {
    assert(!(uintptr_t(_i) & 0x3) && "Invalid alignment");
    _i[0] = _mm_cvtsi128_si32(_v);
    _i[1] = _mm_cvtsi128_si32(OZZ_SSE_SPLAT_I(_v, 1));
}

+ (void)Store3PtrUWith:(_SimdInt4)_v :(int *)_i {
    assert(!(uintptr_t(_i) & 0x3) && "Invalid alignment");
    _i[0] = _mm_cvtsi128_si32(_v);
    _i[1] = _mm_cvtsi128_si32(OZZ_SSE_SPLAT_I(_v, 1));
    _i[2] = _mm_cvtsi128_si32(_mm_unpackhi_epi32(_v, _v));
}

+ (SimdInt4)SplatXWith:(_SimdInt4)_a {
    return OZZ_SSE_SPLAT_I(_a, 0);
}

+ (SimdInt4)SplatYWith:(_SimdInt4)_a {
    return OZZ_SSE_SPLAT_I(_a, 1);
}

+ (SimdInt4)SplatZWith:(_SimdInt4)_a {
    return OZZ_SSE_SPLAT_I(_a, 2);
}

+ (SimdInt4)SplatWWith:(_SimdInt4)_a {
    return OZZ_SSE_SPLAT_I(_a, 3);
}

+ (SimdInt4)Swizzle0123With:(_SimdInt4)_v {
    return _v;
}

+ (int)MoveMaskWith:(_SimdInt4)_v {
    return _mm_movemask_ps(_mm_castsi128_ps(_v));
}

+ (bool)AreAllTrueWith:(_SimdInt4)_v {
    return _mm_movemask_ps(_mm_castsi128_ps(_v)) == 0xf;
}

+ (bool)AreAllTrue3With:(_SimdInt4)_v {
    return (_mm_movemask_ps(_mm_castsi128_ps(_v)) & 0x7) == 0x7;
}

+ (bool)AreAllTrue2With:(_SimdInt4)_v {
    return (_mm_movemask_ps(_mm_castsi128_ps(_v)) & 0x3) == 0x3;
}

+ (bool)AreAllTrue1With:(_SimdInt4)_v {
    return (_mm_movemask_ps(_mm_castsi128_ps(_v)) & 0x1) == 0x1;
}

+ (bool)AreAllFalseWith:(_SimdInt4)_v {
    return _mm_movemask_ps(_mm_castsi128_ps(_v)) == 0;
}

+ (bool)AreAllFalse3With:(_SimdInt4)_v {
    return (_mm_movemask_ps(_mm_castsi128_ps(_v)) & 0x7) == 0;
}

+ (bool)AreAllFalse2With:(_SimdInt4)_v {
    return (_mm_movemask_ps(_mm_castsi128_ps(_v)) & 0x3) == 0;
}

+ (bool)AreAllFalse1With:(_SimdInt4)_v {
    return (_mm_movemask_ps(_mm_castsi128_ps(_v)) & 0x1) == 0;
}

+ (SimdInt4)HAdd2With:(_SimdInt4)_v {
    const __m128i hadd = _mm_add_epi32(_v, OZZ_SSE_SPLAT_I(_v, 1));
    return _mm_castps_si128(
            _mm_move_ss(_mm_castsi128_ps(_v), _mm_castsi128_ps(hadd)));
}

+ (SimdInt4)HAdd3With:(_SimdInt4)_v {
    const __m128i hadd = _mm_add_epi32(_mm_add_epi32(_v, OZZ_SSE_SPLAT_I(_v, 1)),
            _mm_unpackhi_epi32(_v, _v));
    return _mm_castps_si128(
            _mm_move_ss(_mm_castsi128_ps(_v), _mm_castsi128_ps(hadd)));
}

+ (SimdInt4)HAdd4With:(_SimdInt4)_v {
    const __m128 v = _mm_castsi128_ps(_v);
    const __m128i haddxyzw =
            _mm_add_epi32(_v, _mm_castps_si128(_mm_movehl_ps(v, v)));
    return _mm_castps_si128(_mm_move_ss(
            v,
            _mm_castsi128_ps(_mm_add_epi32(haddxyzw, OZZ_SSE_SPLAT_I(haddxyzw, 1)))));
}

+ (SimdInt4)AbsWith:(_SimdInt4)_v {
#ifdef OZZ_SIMD_SSSE3
    return _mm_abs_epi32(_v);
#else   // OZZ_SIMD_SSSE3
    const __m128i zero = _mm_setzero_si128();
    return OZZ_SSE_SELECT_I(_mm_cmplt_epi32(_v, zero), _mm_sub_epi32(zero, _v),
            _v);
#endif  // OZZ_SIMD_SSSE3
}

+ (SimdInt4)SignWith:(_SimdInt4)_v {
    return _mm_slli_epi32(_mm_srli_epi32(_v, 31), 31);
}

+ (SimdInt4)MinWith:(_SimdInt4)_a :(_SimdInt4)_b {
#ifdef OZZ_SIMD_SSE4_1
    return _mm_min_epi32(_a, _b);
#else  // OZZ_SIMD_SSE4_1
    return OZZ_SSE_SELECT_I(_mm_cmplt_epi32(_a, _b), _a, _b);
#endif  // OZZ_SIMD_SSE4_1
}

+ (SimdInt4)MaxWith:(_SimdInt4)_a :(_SimdInt4)_b {
#ifdef OZZ_SIMD_SSE4_1
    return _mm_max_epi32(_a, _b);
#else  // OZZ_SIMD_SSE4_1
    return OZZ_SSE_SELECT_I(_mm_cmpgt_epi32(_a, _b), _a, _b);
#endif  // OZZ_SIMD_SSE4_1
}

+ (SimdInt4)Min0With:(_SimdInt4)_v {
    const __m128i zero = _mm_setzero_si128();
#ifdef OZZ_SIMD_SSE4_1
    return _mm_min_epi32(zero, _v);
#else   // OZZ_SIMD_SSE4_1
    return OZZ_SSE_SELECT_I(_mm_cmplt_epi32(zero, _v), zero, _v);
#endif  // OZZ_SIMD_SSE4_1
}

+ (SimdInt4)Max0With:(_SimdInt4)_v {
    const __m128i zero = _mm_setzero_si128();
#ifdef OZZ_SIMD_SSE4_1
    return _mm_max_epi32(zero, _v);
#else   // OZZ_SIMD_SSE4_1
    return OZZ_SSE_SELECT_I(_mm_cmpgt_epi32(zero, _v), zero, _v);
#endif  // OZZ_SIMD_SSE4_1
}

+ (SimdInt4)ClampWith:(_SimdInt4)_a :(_SimdInt4)_v :(_SimdInt4)_b {
    return _mm_min_epi32(_mm_max_epi32(_a, _v), _b);
}

+ (SimdInt4)SelectWith:(_SimdInt4)_b :(_SimdInt4)_true :(_SimdInt4)_false {
    return OZZ_SSE_SELECT_I(_b, _true, _false);
}

+ (SimdInt4)AndWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return _mm_and_si128(_a, _b);
}

+ (SimdInt4)AndNotWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return _mm_andnot_si128(_b, _a);
}

+ (SimdInt4)OrWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return _mm_or_si128(_a, _b);
}

+ (SimdInt4)XorWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return _mm_xor_si128(_a, _b);
}

+ (SimdInt4)NotWith:(_SimdInt4)_v {
    return _mm_xor_si128(_v, _mm_cmpeq_epi32(_v, _v));
}

+ (SimdInt4)ShiftLWith:(_SimdInt4)_v :(int)_bits {
    return _mm_slli_epi32(_v, _bits);
}

+ (SimdInt4)ShiftRWith:(_SimdInt4)_v :(int)_bits {
    return _mm_srai_epi32(_v, _bits);
}

+ (SimdInt4)ShiftRuWith:(_SimdInt4)_v :(int)_bits {
    return _mm_srli_epi32(_v, _bits);
}

+ (SimdInt4)CmpEqWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return _mm_cmpeq_epi32(_a, _b);
}

+ (SimdInt4)CmpNeWith:(_SimdInt4)_a :(_SimdInt4)_b {
    const __m128i eq = _mm_cmpeq_epi32(_a, _b);
    return _mm_xor_si128(eq, _mm_cmpeq_epi32(_a, _a));
}

+ (SimdInt4)CmpLtWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return _mm_cmpgt_epi32(_b, _a);
}

+ (SimdInt4)CmpLeWith:(_SimdInt4)_a :(_SimdInt4)_b {
    const __m128i gt = _mm_cmpgt_epi32(_a, _b);
    return _mm_xor_si128(gt, _mm_cmpeq_epi32(_a, _a));
}

+ (SimdInt4)CmpGtWith:(_SimdInt4)_a :(_SimdInt4)_b {
    return _mm_cmpgt_epi32(_a, _b);
}

+ (SimdInt4)CmpGeWith:(_SimdInt4)_a :(_SimdInt4)_b {
    const __m128i lt = _mm_cmpgt_epi32(_b, _a);
    return _mm_xor_si128(lt, _mm_cmpeq_epi32(_a, _a));
}


@end

//MARK: - OZZFloat4x4
@implementation OZZFloat4x4

+ (struct Float4x4)identity {
    const __m128i zero = _mm_setzero_si128();
    const __m128i ffff = _mm_cmpeq_epi32(zero, zero);
    const __m128i one = _mm_srli_epi32(_mm_slli_epi32(ffff, 25), 2);
    const __m128i x = _mm_srli_si128(one, 12);
    const Float4x4 ret = {{_mm_castsi128_ps(x),
            _mm_castsi128_ps(_mm_slli_si128(x, 4)),
            _mm_castsi128_ps(_mm_slli_si128(x, 8)),
            _mm_castsi128_ps(_mm_slli_si128(one, 12))}};
    return ret;
}

+ (struct Float4x4)TransposeWith:(const struct Float4x4 *)_m {
    const __m128 tmp0 = _mm_unpacklo_ps(_m->cols[0], _m->cols[2]);
    const __m128 tmp1 = _mm_unpacklo_ps(_m->cols[1], _m->cols[3]);
    const __m128 tmp2 = _mm_unpackhi_ps(_m->cols[0], _m->cols[2]);
    const __m128 tmp3 = _mm_unpackhi_ps(_m->cols[1], _m->cols[3]);
    const Float4x4 ret = {
            {_mm_unpacklo_ps(tmp0, tmp1), _mm_unpackhi_ps(tmp0, tmp1),
                    _mm_unpacklo_ps(tmp2, tmp3), _mm_unpackhi_ps(tmp2, tmp3)}};
    return ret;
}

+ (struct Float4x4)InvertWith:(const struct Float4x4 *)_m :(SimdInt4 *)_invertible {
    const __m128 _t0 =
            _mm_shuffle_ps(_m->cols[0], _m->cols[1], _MM_SHUFFLE(1, 0, 1, 0));
    const __m128 _t1 =
            _mm_shuffle_ps(_m->cols[2], _m->cols[3], _MM_SHUFFLE(1, 0, 1, 0));
    const __m128 _t2 =
            _mm_shuffle_ps(_m->cols[0], _m->cols[1], _MM_SHUFFLE(3, 2, 3, 2));
    const __m128 _t3 =
            _mm_shuffle_ps(_m->cols[2], _m->cols[3], _MM_SHUFFLE(3, 2, 3, 2));
    const __m128 c0 = _mm_shuffle_ps(_t0, _t1, _MM_SHUFFLE(2, 0, 2, 0));
    const __m128 c1 = _mm_shuffle_ps(_t1, _t0, _MM_SHUFFLE(3, 1, 3, 1));
    const __m128 c2 = _mm_shuffle_ps(_t2, _t3, _MM_SHUFFLE(2, 0, 2, 0));
    const __m128 c3 = _mm_shuffle_ps(_t3, _t2, _MM_SHUFFLE(3, 1, 3, 1));

    __m128 minor0, minor1, minor2, minor3, tmp1, tmp2;
    tmp1 = _mm_mul_ps(c2, c3);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0xB1);
    minor0 = _mm_mul_ps(c1, tmp1);
    minor1 = _mm_mul_ps(c0, tmp1);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0x4E);
    minor0 = OZZ_MSUB(c1, tmp1, minor0);
    minor1 = OZZ_MSUB(c0, tmp1, minor1);
    minor1 = OZZ_SHUFFLE_PS1(minor1, 0x4E);

    tmp1 = _mm_mul_ps(c1, c2);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0xB1);
    minor0 = OZZ_MADD(c3, tmp1, minor0);
    minor3 = _mm_mul_ps(c0, tmp1);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0x4E);
    minor0 = OZZ_NMADD(c3, tmp1, minor0);
    minor3 = OZZ_MSUB(c0, tmp1, minor3);
    minor3 = OZZ_SHUFFLE_PS1(minor3, 0x4E);

    tmp1 = _mm_mul_ps(OZZ_SHUFFLE_PS1(c1, 0x4E), c3);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0xB1);
    tmp2 = OZZ_SHUFFLE_PS1(c2, 0x4E);
    minor0 = OZZ_MADD(tmp2, tmp1, minor0);
    minor2 = _mm_mul_ps(c0, tmp1);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0x4E);
    minor0 = OZZ_NMADD(tmp2, tmp1, minor0);
    minor2 = OZZ_MSUB(c0, tmp1, minor2);
    minor2 = OZZ_SHUFFLE_PS1(minor2, 0x4E);

    tmp1 = _mm_mul_ps(c0, c1);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0xB1);
    minor2 = OZZ_MADD(c3, tmp1, minor2);
    minor3 = OZZ_MSUB(tmp2, tmp1, minor3);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0x4E);
    minor2 = OZZ_MSUB(c3, tmp1, minor2);
    minor3 = OZZ_NMADD(tmp2, tmp1, minor3);

    tmp1 = _mm_mul_ps(c0, c3);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0xB1);
    minor1 = OZZ_NMADD(tmp2, tmp1, minor1);
    minor2 = OZZ_MADD(c1, tmp1, minor2);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0x4E);
    minor1 = OZZ_MADD(tmp2, tmp1, minor1);
    minor2 = OZZ_NMADD(c1, tmp1, minor2);

    tmp1 = _mm_mul_ps(c0, tmp2);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0xB1);
    minor1 = OZZ_MADD(c3, tmp1, minor1);
    minor3 = OZZ_NMADD(c1, tmp1, minor3);
    tmp1 = OZZ_SHUFFLE_PS1(tmp1, 0x4E);
    minor1 = OZZ_NMADD(c3, tmp1, minor1);
    minor3 = OZZ_MADD(c1, tmp1, minor3);

    __m128 det;
    det = _mm_mul_ps(c0, minor0);
    det = _mm_add_ps(OZZ_SHUFFLE_PS1(det, 0x4E), det);
    det = _mm_add_ss(OZZ_SHUFFLE_PS1(det, 0xB1), det);
    const SimdInt4 invertible = [OZZFloat4 CmpNeWith:det :[OZZFloat4 zero]];
    assert((_invertible || [OZZInt4 AreAllTrue1With:invertible]) &&
            "Matrix is not invertible");
    if (_invertible != nullptr) {
        *_invertible = invertible;
    }
    tmp1 = OZZ_SSE_SELECT_F(invertible, [OZZFloat4 RcpEstNRWith:det], [OZZFloat4 zero]);
    det = OZZ_NMADDX(det, _mm_mul_ss(tmp1, tmp1), _mm_add_ss(tmp1, tmp1));
    det = OZZ_SHUFFLE_PS1(det, 0x00);

    // Copy the final columns
    const Float4x4 ret = {{_mm_mul_ps(det, minor0), _mm_mul_ps(det, minor1),
            _mm_mul_ps(det, minor2), _mm_mul_ps(det, minor3)}};
    return ret;
}

+ (struct Float4x4)TranslationWith:(_SimdFloat4)_v {
    const __m128i zero = _mm_setzero_si128();
    const __m128i ffff = _mm_cmpeq_epi32(zero, zero);
    const __m128i mask000f = _mm_slli_si128(ffff, 12);
    const __m128i one = _mm_srli_epi32(_mm_slli_epi32(ffff, 25), 2);
    const __m128i x = _mm_srli_si128(one, 12);
    const Float4x4 ret = {
            {_mm_castsi128_ps(x), _mm_castsi128_ps(_mm_slli_si128(x, 4)),
                    _mm_castsi128_ps(_mm_slli_si128(x, 8)),
                    OZZ_SSE_SELECT_F(mask000f, _mm_castsi128_ps(one), _v)}};
    return ret;
}

+ (struct Float4x4)ScalingWith:(_SimdFloat4)_v {
    const __m128i zero = _mm_setzero_si128();
    const __m128i ffff = _mm_cmpeq_epi32(zero, zero);
    const __m128i if000 = _mm_srli_si128(ffff, 12);
    const __m128i ione = _mm_srli_epi32(_mm_slli_epi32(ffff, 25), 2);
    const Float4x4 ret = {
            {
                    _mm_and_ps(_v, _mm_castsi128_ps(if000)),
                    _mm_and_ps(_v, _mm_castsi128_ps(_mm_slli_si128(if000, 4))),
                    _mm_and_ps(_v, _mm_castsi128_ps(_mm_slli_si128(if000, 8))),
                    _mm_castsi128_ps(_mm_slli_si128(ione, 12))
            }
    };
    return ret;
}

+ (struct Float4x4)TranslateWith:(const struct Float4x4 *)_m :(_SimdFloat4)_v {
    const __m128 a01 = OZZ_MADD(_m->cols[0], OZZ_SSE_SPLAT_F(_v, 0),
            _mm_mul_ps(_m->cols[1], OZZ_SSE_SPLAT_F(_v, 1)));
    const __m128 m3 = OZZ_MADD(_m->cols[2], OZZ_SSE_SPLAT_F(_v, 2), _m->cols[3]);
    const Float4x4 ret = {
            {_m->cols[0], _m->cols[1], _m->cols[2], _mm_add_ps(a01, m3)}};
    return ret;
}

+ (struct Float4x4)ScaleWith:(const struct Float4x4 *)_m :(_SimdFloat4)_v {
    const Float4x4 ret = {{_mm_mul_ps(_m->cols[0], OZZ_SSE_SPLAT_F(_v, 0)),
            _mm_mul_ps(_m->cols[1], OZZ_SSE_SPLAT_F(_v, 1)),
            _mm_mul_ps(_m->cols[2], OZZ_SSE_SPLAT_F(_v, 2)),
            _m->cols[3]}};
    return ret;
}

+ (struct Float4x4)ColumnMultiplyWith:(const struct Float4x4 *)_m :(_SimdFloat4)_v {
    const Float4x4 ret = {{_mm_mul_ps(_m->cols[0], _v), _mm_mul_ps(_m->cols[1], _v),
            _mm_mul_ps(_m->cols[2], _v),
            _mm_mul_ps(_m->cols[3], _v)}};
    return ret;
}

+ (SimdInt4)IsNormalizedWith:(const struct Float4x4 *)_m {
    const __m128 max = _mm_set_ps1(1.f + kNormalizationToleranceSq);
    const __m128 min = _mm_set_ps1(1.f - kNormalizationToleranceSq);

    const __m128 tmp0 = _mm_unpacklo_ps(_m->cols[0], _m->cols[2]);
    const __m128 tmp1 = _mm_unpacklo_ps(_m->cols[1], _m->cols[3]);
    const __m128 tmp2 = _mm_unpackhi_ps(_m->cols[0], _m->cols[2]);
    const __m128 tmp3 = _mm_unpackhi_ps(_m->cols[1], _m->cols[3]);
    const __m128 row0 = _mm_unpacklo_ps(tmp0, tmp1);
    const __m128 row1 = _mm_unpackhi_ps(tmp0, tmp1);
    const __m128 row2 = _mm_unpacklo_ps(tmp2, tmp3);

    const __m128 dot =
            OZZ_MADD(row0, row0, OZZ_MADD(row1, row1, _mm_mul_ps(row2, row2)));
    const __m128 normalized =
            _mm_and_ps(_mm_cmplt_ps(dot, max), _mm_cmpgt_ps(dot, min));
    return _mm_castps_si128(
            _mm_and_ps(normalized, _mm_castsi128_ps([OZZInt4 mask_fff0])));
}

+ (SimdInt4)IsNormalizedEstWith:(const struct Float4x4 *)_m {
    const __m128 max = _mm_set_ps1(1.f + kNormalizationToleranceEstSq);
    const __m128 min = _mm_set_ps1(1.f - kNormalizationToleranceEstSq);

    const __m128 tmp0 = _mm_unpacklo_ps(_m->cols[0], _m->cols[2]);
    const __m128 tmp1 = _mm_unpacklo_ps(_m->cols[1], _m->cols[3]);
    const __m128 tmp2 = _mm_unpackhi_ps(_m->cols[0], _m->cols[2]);
    const __m128 tmp3 = _mm_unpackhi_ps(_m->cols[1], _m->cols[3]);
    const __m128 row0 = _mm_unpacklo_ps(tmp0, tmp1);
    const __m128 row1 = _mm_unpackhi_ps(tmp0, tmp1);
    const __m128 row2 = _mm_unpacklo_ps(tmp2, tmp3);

    const __m128 dot =
            OZZ_MADD(row0, row0, OZZ_MADD(row1, row1, _mm_mul_ps(row2, row2)));

    const __m128 normalized =
            _mm_and_ps(_mm_cmplt_ps(dot, max), _mm_cmpgt_ps(dot, min));

    return _mm_castps_si128(
            _mm_and_ps(normalized, _mm_castsi128_ps([OZZInt4 mask_fff0])));
}

+ (SimdInt4)IsOrthogonalWith:(const struct Float4x4 *)_m {
    const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceSq);
    const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceSq);
    const __m128 zero = _mm_setzero_ps();

    // Use simd_float4::zero() if one of the normalization fails. _m will then be
    // considered not orthogonal.
    const SimdFloat4 cross = [OZZFloat4 NormalizeSafe3With:[OZZFloat4 Cross3With:_m->cols[0] :_m->cols[1]] :zero];
    const SimdFloat4 at = [OZZFloat4 NormalizeSafe3With:_m->cols[2] :zero];

    SimdFloat4 dot;
    OZZ_SSE_DOT3_F(cross, at, dot);
    __m128 dotx000 = _mm_move_ss(zero, dot);
    return _mm_castps_si128(
            _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdFloat4)ToQuaternionWith:(const struct Float4x4 *)_m {
    assert([OZZInt4 AreAllTrue3With:[OZZFloat4x4 IsNormalizedEstWith:_m]]);
    assert([OZZInt4 AreAllTrue1With:[OZZFloat4x4 IsOrthogonalWith:_m]]);

    // Prepares constants.
    const __m128i zero = _mm_setzero_si128();
    const __m128i ffff = _mm_cmpeq_epi32(zero, zero);
    const __m128 half = _mm_set1_ps(0.5f);
    const __m128i mask_f000 = _mm_srli_si128(ffff, 12);
    const __m128i mask_000f = _mm_slli_si128(ffff, 12);
    const __m128 one =
            _mm_castsi128_ps(_mm_srli_epi32(_mm_slli_epi32(ffff, 25), 2));
    const __m128i mask_0f00 = _mm_slli_si128(mask_f000, 4);
    const __m128i mask_00f0 = _mm_slli_si128(mask_f000, 8);

    const __m128 xx_yy = OZZ_SSE_SELECT_F(mask_0f00, _m->cols[1], _m->cols[0]);
    const __m128 xx_yy_0010 = OZZ_SHUFFLE_PS1(xx_yy, _MM_SHUFFLE(0, 0, 1, 0));
    const __m128 xx_yy_zz_xx =
            OZZ_SSE_SELECT_F(mask_00f0, _m->cols[2], xx_yy_0010);
    const __m128 yy_zz_xx_yy =
            OZZ_SHUFFLE_PS1(xx_yy_zz_xx, _MM_SHUFFLE(1, 0, 2, 1));
    const __m128 zz_xx_yy_zz =
            OZZ_SHUFFLE_PS1(xx_yy_zz_xx, _MM_SHUFFLE(2, 1, 0, 2));

    const __m128 diag_sum =
            _mm_add_ps(_mm_add_ps(xx_yy_zz_xx, yy_zz_xx_yy), zz_xx_yy_zz);
    const __m128 diag_diff =
            _mm_sub_ps(_mm_sub_ps(xx_yy_zz_xx, yy_zz_xx_yy), zz_xx_yy_zz);
    const __m128 radicand =
            _mm_add_ps(OZZ_SSE_SELECT_F(mask_000f, diag_sum, diag_diff), one);
    const __m128 invSqrt = one / _mm_sqrt_ps(radicand);

    __m128 zy_xz_yx = OZZ_SSE_SELECT_F(mask_00f0, _m->cols[1], _m->cols[0]);
    zy_xz_yx = OZZ_SHUFFLE_PS1(zy_xz_yx, _MM_SHUFFLE(0, 1, 2, 2));
    zy_xz_yx =
            OZZ_SSE_SELECT_F(mask_0f00, OZZ_SSE_SPLAT_F(_m->cols[2], 0), zy_xz_yx);
    __m128 yz_zx_xy = OZZ_SSE_SELECT_F(mask_f000, _m->cols[1], _m->cols[0]);
    yz_zx_xy = OZZ_SHUFFLE_PS1(yz_zx_xy, _MM_SHUFFLE(0, 0, 2, 0));
    yz_zx_xy =
            OZZ_SSE_SELECT_F(mask_f000, OZZ_SSE_SPLAT_F(_m->cols[2], 1), yz_zx_xy);
    const __m128 sum = _mm_add_ps(zy_xz_yx, yz_zx_xy);
    const __m128 diff = _mm_sub_ps(zy_xz_yx, yz_zx_xy);
    const __m128 scale = _mm_mul_ps(invSqrt, half);

    const __m128 sum0 = OZZ_SHUFFLE_PS1(sum, _MM_SHUFFLE(0, 1, 2, 0));
    const __m128 sum1 = OZZ_SHUFFLE_PS1(sum, _MM_SHUFFLE(0, 0, 0, 2));
    const __m128 sum2 = OZZ_SHUFFLE_PS1(sum, _MM_SHUFFLE(0, 0, 0, 1));
    __m128 res0 = OZZ_SSE_SELECT_F(mask_000f, OZZ_SSE_SPLAT_F(diff, 0), sum0);
    __m128 res1 = OZZ_SSE_SELECT_F(mask_000f, OZZ_SSE_SPLAT_F(diff, 1), sum1);
    __m128 res2 = OZZ_SSE_SELECT_F(mask_000f, OZZ_SSE_SPLAT_F(diff, 2), sum2);
    res0 = _mm_mul_ps(OZZ_SSE_SELECT_F(mask_f000, radicand, res0),
            OZZ_SSE_SPLAT_F(scale, 0));
    res1 = _mm_mul_ps(OZZ_SSE_SELECT_F(mask_0f00, radicand, res1),
            OZZ_SSE_SPLAT_F(scale, 1));
    res2 = _mm_mul_ps(OZZ_SSE_SELECT_F(mask_00f0, radicand, res2),
            OZZ_SSE_SPLAT_F(scale, 2));
    __m128 res3 = _mm_mul_ps(OZZ_SSE_SELECT_F(mask_000f, radicand, diff),
            OZZ_SSE_SPLAT_F(scale, 3));

    const __m128 xx = OZZ_SSE_SPLAT_F(_m->cols[0], 0);
    const __m128 yy = OZZ_SSE_SPLAT_F(_m->cols[1], 1);
    const __m128 zz = OZZ_SSE_SPLAT_F(_m->cols[2], 2);
    const __m128i cond0 = _mm_castps_si128(_mm_cmpgt_ps(yy, xx));
    const __m128i cond1 =
            _mm_castps_si128(_mm_and_ps(_mm_cmpgt_ps(zz, xx), _mm_cmpgt_ps(zz, yy)));
    const __m128i cond2 = _mm_castps_si128(
            _mm_cmpgt_ps(OZZ_SSE_SPLAT_F(diag_sum, 0), _mm_castsi128_ps(zero)));
    __m128 res = OZZ_SSE_SELECT_F(cond0, res1, res0);
    res = OZZ_SSE_SELECT_F(cond1, res2, res);
    res = OZZ_SSE_SELECT_F(cond2, res3, res);

    assert([OZZInt4 AreAllTrue1With:[OZZFloat4 IsNormalizedEst4With:res]]);
    return res;
}

+ (bool)ToAffineWith:(const struct Float4x4 *)_m :(SimdFloat4 *)_translation
        :(SimdFloat4 *)_quaternion :(SimdFloat4 *)_scale {
    const __m128 zero = _mm_setzero_ps();
    const __m128 one = [OZZFloat4 one];
    const __m128i fff0 = [OZZInt4 mask_fff0];
    const __m128 max = _mm_set_ps1(kOrthogonalisationToleranceSq);
    const __m128 min = _mm_set_ps1(-kOrthogonalisationToleranceSq);

    // Extracts translation.
    *_translation = OZZ_SSE_SELECT_F(fff0, _m->cols[3], one);

    // Extracts scale.
    const __m128 m_tmp0 = _mm_unpacklo_ps(_m->cols[0], _m->cols[2]);
    const __m128 m_tmp1 = _mm_unpacklo_ps(_m->cols[1], _m->cols[3]);
    const __m128 m_tmp2 = _mm_unpackhi_ps(_m->cols[0], _m->cols[2]);
    const __m128 m_tmp3 = _mm_unpackhi_ps(_m->cols[1], _m->cols[3]);
    const __m128 m_row0 = _mm_unpacklo_ps(m_tmp0, m_tmp1);
    const __m128 m_row1 = _mm_unpackhi_ps(m_tmp0, m_tmp1);
    const __m128 m_row2 = _mm_unpacklo_ps(m_tmp2, m_tmp3);

    const __m128 dot = OZZ_MADD(
            m_row0, m_row0, OZZ_MADD(m_row1, m_row1, _mm_mul_ps(m_row2, m_row2)));
    const __m128 abs_scale = _mm_sqrt_ps(dot);

    const __m128 zero_axis =
            _mm_and_ps(_mm_cmplt_ps(dot, max), _mm_cmpgt_ps(dot, min));

    // Builds an orthonormal matrix in order to support quaternion extraction.
    Float4x4 orthonormal;
    int mask = _mm_movemask_ps(zero_axis);
    if (mask & 1) {
        if (mask & 6) {
            return false;
        }
        orthonormal.cols[1] = _mm_div_ps(_m->cols[1], OZZ_SSE_SPLAT_F(abs_scale, 1));
        orthonormal.cols[0] = [OZZFloat4 Normalize3With:[OZZFloat4 Cross3With:orthonormal.cols[1] :_m->cols[2]]];
        orthonormal.cols[2] = [OZZFloat4 Normalize3With:[OZZFloat4 Cross3With:orthonormal.cols[0] :orthonormal.cols[1]]];
    } else if (mask & 4) {
        if (mask & 3) {
            return false;
        }
        orthonormal.cols[0] = _mm_div_ps(_m->cols[0], OZZ_SSE_SPLAT_F(abs_scale, 0));
        orthonormal.cols[2] = [OZZFloat4 Normalize3With:[OZZFloat4 Cross3With:orthonormal.cols[0] :_m->cols[1]]];
        orthonormal.cols[1] = [OZZFloat4 Normalize3With:[OZZFloat4 Cross3With:orthonormal.cols[2] :orthonormal.cols[0]]];
    } else {  // Favor z axis in the default case
        if (mask & 5) {
            return false;
        }
        orthonormal.cols[2] = _mm_div_ps(_m->cols[2], OZZ_SSE_SPLAT_F(abs_scale, 2));
        orthonormal.cols[1] = [OZZFloat4 Normalize3With:[OZZFloat4 Cross3With:orthonormal.cols[2] :_m->cols[0]]];
        orthonormal.cols[0] = [OZZFloat4 Normalize3With:[OZZFloat4 Cross3With:orthonormal.cols[1] :orthonormal.cols[2]]];
    }
    orthonormal.cols[3] = [OZZFloat4 w_axis];

    // Get back scale signs in case of reflexions
    const __m128 o_tmp0 =
            _mm_unpacklo_ps(orthonormal.cols[0], orthonormal.cols[2]);
    const __m128 o_tmp1 =
            _mm_unpacklo_ps(orthonormal.cols[1], orthonormal.cols[3]);
    const __m128 o_tmp2 =
            _mm_unpackhi_ps(orthonormal.cols[0], orthonormal.cols[2]);
    const __m128 o_tmp3 =
            _mm_unpackhi_ps(orthonormal.cols[1], orthonormal.cols[3]);
    const __m128 o_row0 = _mm_unpacklo_ps(o_tmp0, o_tmp1);
    const __m128 o_row1 = _mm_unpackhi_ps(o_tmp0, o_tmp1);
    const __m128 o_row2 = _mm_unpacklo_ps(o_tmp2, o_tmp3);

    const __m128 scale_dot = OZZ_MADD(
            o_row0, m_row0, OZZ_MADD(o_row1, m_row1, _mm_mul_ps(o_row2, m_row2)));

    const __m128i cond = _mm_castps_si128(_mm_cmpgt_ps(scale_dot, zero));
    const __m128 cfalse = _mm_sub_ps(zero, abs_scale);
    const __m128 scale = OZZ_SSE_SELECT_F(cond, abs_scale, cfalse);
    *_scale = OZZ_SSE_SELECT_F(fff0, scale, one);

    // Extracts quaternion.
    *_quaternion = [OZZFloat4x4 ToQuaternionWith:&orthonormal];
    return true;
}

+ (Float4x4)FromEulerWith:(_SimdFloat4)_v {
    const __m128 cos = [OZZFloat4 CosWith:_v];
    const __m128 sin = [OZZFloat4 SinWith:_v];

    const float cx = [OZZFloat4 GetXWith:cos];
    const float sx = [OZZFloat4 GetXWith:sin];
    const float cy = [OZZFloat4 GetYWith:cos];
    const float sy = [OZZFloat4 GetYWith:sin];
    const float cz = [OZZFloat4 GetZWith:cos];
    const float sz = [OZZFloat4 GetZWith:sin];

    const float sycz = sy * cz;
    const float sysz = sy * sz;

    const Float4x4 ret = {{[OZZFloat4 LoadWith:cx * cy :sx * sz - cx * sycz
            :cx * sysz + sx * cz :0.f],
            [OZZFloat4 LoadWith:sy :cy * cz :-cy * sz :0.f],
            [OZZFloat4 LoadWith:-sx * cy :sx * sycz + cx * sz
                    :-sx * sysz + cx * cz :0.f],
            [OZZFloat4 w_axis]}};
    return ret;
}

+ (Float4x4)FromAxisAngleWith:(_SimdFloat4)_axis :(_SimdFloat4)_angle {
    assert([OZZInt4 AreAllTrue1With:[OZZFloat4 IsNormalizedEst3With:_axis]]);

    const __m128i zero = _mm_setzero_si128();
    const __m128i ffff = _mm_cmpeq_epi32(zero, zero);
    const __m128i ione = _mm_srli_epi32(_mm_slli_epi32(ffff, 25), 2);
    const __m128 fff0 = _mm_castsi128_ps(_mm_srli_si128(ffff, 4));
    const __m128 one = _mm_castsi128_ps(ione);
    const __m128 w_axis = _mm_castsi128_ps(_mm_slli_si128(ione, 12));

    const __m128 sin = [OZZFloat4 SplatXWith:[OZZFloat4 SinXWith:_angle]];
    const __m128 cos = [OZZFloat4 SplatXWith:[OZZFloat4 CosXWith:_angle]];
    const __m128 one_minus_cos = _mm_sub_ps(one, cos);

    const __m128 v0 =
            _mm_mul_ps(_mm_mul_ps(one_minus_cos,
                            OZZ_SHUFFLE_PS1(_axis, _MM_SHUFFLE(3, 0, 2, 1))),
                    OZZ_SHUFFLE_PS1(_axis, _MM_SHUFFLE(3, 1, 0, 2)));
    const __m128 r0 =
            _mm_add_ps(_mm_mul_ps(_mm_mul_ps(one_minus_cos, _axis), _axis), cos);
    const __m128 r1 = _mm_add_ps(_mm_mul_ps(sin, _axis), v0);
    const __m128 r2 = _mm_sub_ps(v0, _mm_mul_ps(sin, _axis));
    const __m128 r0fff0 = _mm_and_ps(r0, fff0);
    const __m128 r1r22120 = _mm_shuffle_ps(r1, r2, _MM_SHUFFLE(2, 1, 2, 0));
    const __m128 v1 = OZZ_SHUFFLE_PS1(r1r22120, _MM_SHUFFLE(0, 3, 2, 1));
    const __m128 r1r20011 = _mm_shuffle_ps(r1, r2, _MM_SHUFFLE(0, 0, 1, 1));
    const __m128 v2 = OZZ_SHUFFLE_PS1(r1r20011, _MM_SHUFFLE(2, 0, 2, 0));

    const __m128 t0 = _mm_shuffle_ps(r0fff0, v1, _MM_SHUFFLE(1, 0, 3, 0));
    const __m128 t1 = _mm_shuffle_ps(r0fff0, v1, _MM_SHUFFLE(3, 2, 3, 1));
    const Float4x4 ret = {{OZZ_SHUFFLE_PS1(t0, _MM_SHUFFLE(1, 3, 2, 0)),
            OZZ_SHUFFLE_PS1(t1, _MM_SHUFFLE(1, 3, 0, 2)),
            _mm_shuffle_ps(v2, r0fff0, _MM_SHUFFLE(3, 2, 1, 0)),
            w_axis}};
    return ret;
}

+ (Float4x4)FromQuaternionWith:(_SimdFloat4)_quaternion {
    assert([OZZInt4 AreAllTrue1With:[OZZFloat4 IsNormalizedEst4With:_quaternion]]);

    const __m128i zero = _mm_setzero_si128();
    const __m128i ffff = _mm_cmpeq_epi32(zero, zero);
    const __m128i ione = _mm_srli_epi32(_mm_slli_epi32(ffff, 25), 2);
    const __m128 fff0 = _mm_castsi128_ps(_mm_srli_si128(ffff, 4));
    const __m128 c1110 = _mm_castsi128_ps(_mm_srli_si128(ione, 4));
    const __m128 w_axis = _mm_castsi128_ps(_mm_slli_si128(ione, 12));

    const __m128 vsum = _mm_add_ps(_quaternion, _quaternion);
    const __m128 vms = _mm_mul_ps(_quaternion, vsum);

    const __m128 r0 = _mm_sub_ps(
            _mm_sub_ps(
                    c1110,
                    _mm_and_ps(OZZ_SHUFFLE_PS1(vms, _MM_SHUFFLE(3, 0, 0, 1)), fff0)),
            _mm_and_ps(OZZ_SHUFFLE_PS1(vms, _MM_SHUFFLE(3, 1, 2, 2)), fff0));
    const __m128 v0 =
            _mm_mul_ps(OZZ_SHUFFLE_PS1(_quaternion, _MM_SHUFFLE(3, 1, 0, 0)),
                    OZZ_SHUFFLE_PS1(vsum, _MM_SHUFFLE(3, 2, 1, 2)));
    const __m128 v1 =
            _mm_mul_ps(OZZ_SHUFFLE_PS1(_quaternion, _MM_SHUFFLE(3, 3, 3, 3)),
                    OZZ_SHUFFLE_PS1(vsum, _MM_SHUFFLE(3, 0, 2, 1)));

    const __m128 r1 = _mm_add_ps(v0, v1);
    const __m128 r2 = _mm_sub_ps(v0, v1);

    const __m128 r1r21021 = _mm_shuffle_ps(r1, r2, _MM_SHUFFLE(1, 0, 2, 1));
    const __m128 v2 = OZZ_SHUFFLE_PS1(r1r21021, _MM_SHUFFLE(1, 3, 2, 0));
    const __m128 r1r22200 = _mm_shuffle_ps(r1, r2, _MM_SHUFFLE(2, 2, 0, 0));
    const __m128 v3 = OZZ_SHUFFLE_PS1(r1r22200, _MM_SHUFFLE(2, 0, 2, 0));

    const __m128 q0 = _mm_shuffle_ps(r0, v2, _MM_SHUFFLE(1, 0, 3, 0));
    const __m128 q1 = _mm_shuffle_ps(r0, v2, _MM_SHUFFLE(3, 2, 3, 1));
    const Float4x4 ret = {{OZZ_SHUFFLE_PS1(q0, _MM_SHUFFLE(1, 3, 2, 0)),
            OZZ_SHUFFLE_PS1(q1, _MM_SHUFFLE(1, 3, 0, 2)),
            _mm_shuffle_ps(v3, r0, _MM_SHUFFLE(3, 2, 1, 0)),
            w_axis}};
    return ret;
}

+ (Float4x4)FromAffineWith:(_SimdFloat4)_translation
        :(_SimdFloat4)_quaternion
        :(_SimdFloat4)_scale {
    assert([OZZInt4 AreAllTrue1With:[OZZFloat4 IsNormalizedEst4With:_quaternion]]);

    const __m128i zero = _mm_setzero_si128();
    const __m128i ffff = _mm_cmpeq_epi32(zero, zero);
    const __m128i ione = _mm_srli_epi32(_mm_slli_epi32(ffff, 25), 2);
    const __m128 fff0 = _mm_castsi128_ps(_mm_srli_si128(ffff, 4));
    const __m128 c1110 = _mm_castsi128_ps(_mm_srli_si128(ione, 4));

    const __m128 vsum = _mm_add_ps(_quaternion, _quaternion);
    const __m128 vms = _mm_mul_ps(_quaternion, vsum);

    const __m128 r0 = _mm_sub_ps(
            _mm_sub_ps(
                    c1110,
                    _mm_and_ps(OZZ_SHUFFLE_PS1(vms, _MM_SHUFFLE(3, 0, 0, 1)), fff0)),
            _mm_and_ps(OZZ_SHUFFLE_PS1(vms, _MM_SHUFFLE(3, 1, 2, 2)), fff0));
    const __m128 v0 =
            _mm_mul_ps(OZZ_SHUFFLE_PS1(_quaternion, _MM_SHUFFLE(3, 1, 0, 0)),
                    OZZ_SHUFFLE_PS1(vsum, _MM_SHUFFLE(3, 2, 1, 2)));
    const __m128 v1 =
            _mm_mul_ps(OZZ_SHUFFLE_PS1(_quaternion, _MM_SHUFFLE(3, 3, 3, 3)),
                    OZZ_SHUFFLE_PS1(vsum, _MM_SHUFFLE(3, 0, 2, 1)));

    const __m128 r1 = _mm_add_ps(v0, v1);
    const __m128 r2 = _mm_sub_ps(v0, v1);

    const __m128 r1r21021 = _mm_shuffle_ps(r1, r2, _MM_SHUFFLE(1, 0, 2, 1));
    const __m128 v2 = OZZ_SHUFFLE_PS1(r1r21021, _MM_SHUFFLE(1, 3, 2, 0));
    const __m128 r1r22200 = _mm_shuffle_ps(r1, r2, _MM_SHUFFLE(2, 2, 0, 0));
    const __m128 v3 = OZZ_SHUFFLE_PS1(r1r22200, _MM_SHUFFLE(2, 0, 2, 0));

    const __m128 q0 = _mm_shuffle_ps(r0, v2, _MM_SHUFFLE(1, 0, 3, 0));
    const __m128 q1 = _mm_shuffle_ps(r0, v2, _MM_SHUFFLE(3, 2, 3, 1));

    const Float4x4 ret = {
            {_mm_mul_ps(OZZ_SHUFFLE_PS1(q0, _MM_SHUFFLE(1, 3, 2, 0)),
                    OZZ_SSE_SPLAT_F(_scale, 0)),
                    _mm_mul_ps(OZZ_SHUFFLE_PS1(q1, _MM_SHUFFLE(1, 3, 0, 2)),
                            OZZ_SSE_SPLAT_F(_scale, 1)),
                    _mm_mul_ps(_mm_shuffle_ps(v3, r0, _MM_SHUFFLE(3, 2, 1, 0)),
                            OZZ_SSE_SPLAT_F(_scale, 2)),
                    _mm_movelh_ps(_translation, _mm_unpackhi_ps(_translation, c1110))}};
    return ret;
}

+ (SimdFloat4)TransformPointWith:(const struct Float4x4 *)_m
        :(_SimdFloat4)_v {
    const __m128 xxxx = _mm_mul_ps(OZZ_SSE_SPLAT_F(_v, 0), _m->cols[0]);
    const __m128 a23 = OZZ_MADD(OZZ_SSE_SPLAT_F(_v, 2), _m->cols[2], _m->cols[3]);
    const __m128 a01 = OZZ_MADD(OZZ_SSE_SPLAT_F(_v, 1), _m->cols[1], xxxx);
    return _mm_add_ps(a01, a23);
}

+ (SimdFloat4)TransformVectorWith:(const struct Float4x4 *)_m
        :(_SimdFloat4)_v {
    const __m128 xxxx = _mm_mul_ps(_m->cols[0], OZZ_SSE_SPLAT_F(_v, 0));
    const __m128 zzzz = _mm_mul_ps(_m->cols[1], OZZ_SSE_SPLAT_F(_v, 1));
    const __m128 a21 = OZZ_MADD(_m->cols[2], OZZ_SSE_SPLAT_F(_v, 2), xxxx);
    return _mm_add_ps(zzzz, a21);
}

+ (SimdFloat4)MulWith:(const struct Float4x4 *)_m
                  vec:(_SimdFloat4)_v {
    const __m128 xxxx = _mm_mul_ps(OZZ_SSE_SPLAT_F(_v, 0), _m->cols[0]);
    const __m128 zzzz = _mm_mul_ps(OZZ_SSE_SPLAT_F(_v, 2), _m->cols[2]);
    const __m128 a01 = OZZ_MADD(OZZ_SSE_SPLAT_F(_v, 1), _m->cols[1], xxxx);
    const __m128 a23 = OZZ_MADD(OZZ_SSE_SPLAT_F(_v, 3), _m->cols[3], zzzz);
    return _mm_add_ps(a01, a23);
}

+ (struct Float4x4)MulWith:(const struct Float4x4 *)_a
                       mat:(const struct Float4x4 *)_b {
    Float4x4 ret;
    {
        const __m128 xxxx = _mm_mul_ps(OZZ_SSE_SPLAT_F(_b->cols[0], 0), _a->cols[0]);
        const __m128 zzzz = _mm_mul_ps(OZZ_SSE_SPLAT_F(_b->cols[0], 2), _a->cols[2]);
        const __m128 a01 =
                OZZ_MADD(OZZ_SSE_SPLAT_F(_b->cols[0], 1), _a->cols[1], xxxx);
        const __m128 a23 =
                OZZ_MADD(OZZ_SSE_SPLAT_F(_b->cols[0], 3), _a->cols[3], zzzz);
        ret.cols[0] = _mm_add_ps(a01, a23);
    }
    {
        const __m128 xxxx = _mm_mul_ps(OZZ_SSE_SPLAT_F(_b->cols[1], 0), _a->cols[0]);
        const __m128 zzzz = _mm_mul_ps(OZZ_SSE_SPLAT_F(_b->cols[1], 2), _a->cols[2]);
        const __m128 a01 =
                OZZ_MADD(OZZ_SSE_SPLAT_F(_b->cols[1], 1), _a->cols[1], xxxx);
        const __m128 a23 =
                OZZ_MADD(OZZ_SSE_SPLAT_F(_b->cols[1], 3), _a->cols[3], zzzz);
        ret.cols[1] = _mm_add_ps(a01, a23);
    }
    {
        const __m128 xxxx = _mm_mul_ps(OZZ_SSE_SPLAT_F(_b->cols[2], 0), _a->cols[0]);
        const __m128 zzzz = _mm_mul_ps(OZZ_SSE_SPLAT_F(_b->cols[2], 2), _a->cols[2]);
        const __m128 a01 =
                OZZ_MADD(OZZ_SSE_SPLAT_F(_b->cols[2], 1), _a->cols[1], xxxx);
        const __m128 a23 =
                OZZ_MADD(OZZ_SSE_SPLAT_F(_b->cols[2], 3), _a->cols[3], zzzz);
        ret.cols[2] = _mm_add_ps(a01, a23);
    }
    {
        const __m128 xxxx = _mm_mul_ps(OZZ_SSE_SPLAT_F(_b->cols[3], 0), _a->cols[0]);
        const __m128 zzzz = _mm_mul_ps(OZZ_SSE_SPLAT_F(_b->cols[3], 2), _a->cols[2]);
        const __m128 a01 =
                OZZ_MADD(OZZ_SSE_SPLAT_F(_b->cols[3], 1), _a->cols[1], xxxx);
        const __m128 a23 =
                OZZ_MADD(OZZ_SSE_SPLAT_F(_b->cols[3], 3), _a->cols[3], zzzz);
        ret.cols[3] = _mm_add_ps(a01, a23);
    }
    return ret;
}

+ (struct Float4x4)AddWith:(const struct Float4x4 *)_a
        :(const struct Float4x4 *)_b {
    const Float4x4 ret = {
            {_mm_add_ps(_a->cols[0], _b->cols[0]), _mm_add_ps(_a->cols[1], _b->cols[1]),
                    _mm_add_ps(_a->cols[2], _b->cols[2]), _mm_add_ps(_a->cols[3], _b->cols[3])}};
    return ret;
}

+ (struct Float4x4)SubWith:(const struct Float4x4 *)_a
        :(const struct Float4x4 *)_b {
    const Float4x4 ret = {
            {_mm_sub_ps(_a->cols[0], _b->cols[0]), _mm_sub_ps(_a->cols[1], _b->cols[1]),
                    _mm_sub_ps(_a->cols[2], _b->cols[2]), _mm_sub_ps(_a->cols[3], _b->cols[3])}};
    return ret;
}

@end

//MARK: - OZZMath
@implementation OZZMath

+ (uint16_t)FloatToHalfWith:(float)_f {
    const int h = _mm_cvtsi128_si32([OZZMath FloatToHalfWithSIMD:_mm_set1_ps(_f)]);
    return static_cast<uint16_t>(h);
}

+ (float)HalfToFloatWith:(uint16_t)_h {
    return _mm_cvtss_f32([OZZMath HalfToFloatWithSIMD:_mm_set1_epi32(_h)]);
}

+ (SimdInt4)FloatToHalfWithSIMD:(_SimdFloat4)_f {
    const __m128i mask_sign = _mm_set1_epi32(0x80000000u);
    const __m128i mask_round = _mm_set1_epi32(~0xfffu);
    const __m128i f32infty = _mm_set1_epi32(255 << 23);
    const __m128 magic = _mm_castsi128_ps(_mm_set1_epi32(15 << 23));
    const __m128i nanbit = _mm_set1_epi32(0x200);
    const __m128i infty_as_fp16 = _mm_set1_epi32(0x7c00);
    const __m128 clamp = _mm_castsi128_ps(_mm_set1_epi32((31 << 23) - 0x1000));

    const __m128 msign = _mm_castsi128_ps(mask_sign);
    const __m128 justsign = _mm_and_ps(msign, _f);
    const __m128 absf = _mm_xor_ps(_f, justsign);
    const __m128 mround = _mm_castsi128_ps(mask_round);
    const __m128i absf_int = _mm_castps_si128(absf);
    const __m128i b_isnan = _mm_cmpgt_epi32(absf_int, f32infty);
    const __m128i b_isnormal = _mm_cmpgt_epi32(f32infty, _mm_castps_si128(absf));
    const __m128i inf_or_nan =
            _mm_or_si128(_mm_and_si128(b_isnan, nanbit), infty_as_fp16);
    const __m128 fnosticky = _mm_and_ps(absf, mround);
    const __m128 scaled = _mm_mul_ps(fnosticky, magic);
    // Logically, we want PMINSD on "biased", but this should gen better code
    const __m128 clamped = _mm_min_ps(scaled, clamp);
    const __m128i biased =
            _mm_sub_epi32(_mm_castps_si128(clamped), _mm_castps_si128(mround));
    const __m128i shifted = _mm_srli_epi32(biased, 13);
    const __m128i normal = _mm_and_si128(shifted, b_isnormal);
    const __m128i not_normal = _mm_andnot_si128(b_isnormal, inf_or_nan);
    const __m128i joined = _mm_or_si128(normal, not_normal);

    const __m128i sign_shift = _mm_srli_epi32(_mm_castps_si128(justsign), 16);
    return _mm_or_si128(joined, sign_shift);
}

+ (SimdFloat4)HalfToFloatWithSIMD:(_SimdInt4)_h {
    const __m128i mask_nosign = _mm_set1_epi32(0x7fff);
    const __m128 magic = _mm_castsi128_ps(_mm_set1_epi32((254 - 15) << 23));
    const __m128i was_infnan = _mm_set1_epi32(0x7bff);
    const __m128 exp_infnan = _mm_castsi128_ps(_mm_set1_epi32(255 << 23));

    const __m128i expmant = _mm_and_si128(mask_nosign, _h);
    const __m128i shifted = _mm_slli_epi32(expmant, 13);
    const __m128 scaled = _mm_mul_ps(_mm_castsi128_ps(shifted), magic);
    const __m128i b_wasinfnan = _mm_cmpgt_epi32(expmant, was_infnan);
    const __m128i sign = _mm_slli_epi32(_mm_xor_si128(_h, expmant), 16);
    const __m128 infnanexp =
            _mm_and_ps(_mm_castsi128_ps(b_wasinfnan), exp_infnan);
    const __m128 sign_inf = _mm_or_ps(_mm_castsi128_ps(sign), infnanexp);
    return _mm_or_ps(scaled, sign_inf);
}

@end
