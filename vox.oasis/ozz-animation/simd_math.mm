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

+ (SimdFloat4) Dot2With:(_SimdFloat4) _a :(_SimdFloat4) _b {
  __m128 dot2;
  OZZ_SSE_DOT2_F(_a, _b, dot2);
  return dot2;
}

+ (SimdFloat4) Dot3With:(_SimdFloat4) _a :(_SimdFloat4) _b {
  __m128 dot3;
  OZZ_SSE_DOT3_F(_a, _b, dot3);
  return dot3;
}

+ (SimdFloat4) Dot4With:(_SimdFloat4) _a :(_SimdFloat4) _b {
  __m128 dot4;
  OZZ_SSE_DOT4_F(_a, _b, dot4);
  return dot4;
}

+ (SimdFloat4) Cross3With:(_SimdFloat4) _a :(_SimdFloat4) _b {
  // Implementation with 3 shuffles only is based on:
  // https://geometrian.com/programming/tutorials/cross-product
  const __m128 shufa = OZZ_SHUFFLE_PS1(_a, _MM_SHUFFLE(3, 0, 2, 1));
  const __m128 shufb = OZZ_SHUFFLE_PS1(_b, _MM_SHUFFLE(3, 0, 2, 1));
  const __m128 shufc = OZZ_MSUB(_a, shufb, _mm_mul_ps(_b, shufa));
  return OZZ_SHUFFLE_PS1(shufc, _MM_SHUFFLE(3, 0, 2, 1));
}

+ (SimdFloat4) RcpEstWith:(_SimdFloat4) _v {
    return _mm_rcp_ps(_v);
}

+ (SimdFloat4) RcpEstNRWith:(_SimdFloat4) _v {
  const __m128 nr = _mm_rcp_ps(_v);
  // Do one more Newton-Raphson step to improve precision.
  return OZZ_NMADD(_mm_mul_ps(nr, nr), _v, _mm_add_ps(nr, nr));
}

+ (SimdFloat4) RcpEstXWith:(_SimdFloat4) _v { return _mm_rcp_ss(_v); }

+ (SimdFloat4) RcpEstXNRWith:(_SimdFloat4) _v {
  const __m128 nr = _mm_rcp_ss(_v);
  // Do one more Newton-Raphson step to improve precision.
  return OZZ_NMADDX(_mm_mul_ss(nr, nr), _v, _mm_add_ss(nr, nr));
}

+ (SimdFloat4) SqrtWith:(_SimdFloat4) _v { return _mm_sqrt_ps(_v); }

+ (SimdFloat4) SqrtXWith:(_SimdFloat4) _v { return _mm_sqrt_ss(_v); }

+ (SimdFloat4) RSqrtEstWith:(_SimdFloat4) _v { return _mm_rsqrt_ps(_v); }

+ (SimdFloat4) RSqrtEstNRWith:(_SimdFloat4) _v {
  const __m128 nr = _mm_rsqrt_ps(_v);
  // Do one more Newton-Raphson step to improve precision.
  return _mm_mul_ps(_mm_mul_ps(_mm_set_ps1(.5f), nr),
                    OZZ_NMADD(_mm_mul_ps(_v, nr), nr, _mm_set_ps1(3.f)));
}

+ (SimdFloat4) RSqrtEstXWith:(_SimdFloat4) _v { return _mm_rsqrt_ss(_v); }

+ (SimdFloat4) RSqrtEstXNRWith:(_SimdFloat4) _v {
  const __m128 nr = _mm_rsqrt_ss(_v);
  // Do one more Newton-Raphson step to improve precision.
  return _mm_mul_ss(_mm_mul_ss(_mm_set_ps1(.5f), nr),
                    OZZ_NMADDX(_mm_mul_ss(_v, nr), nr, _mm_set_ps1(3.f)));
}

+ (SimdFloat4) AbsWith:(_SimdFloat4) _v {
  const __m128i zero = _mm_setzero_si128();
  return _mm_and_ps(
      _mm_castsi128_ps(_mm_srli_epi32(_mm_cmpeq_epi32(zero, zero), 1)), _v);
}

+ (SimdInt4) SignWith:(_SimdFloat4) _v {
  return _mm_slli_epi32(_mm_srli_epi32(_mm_castps_si128(_v), 31), 31);
}

+ (SimdFloat4) Length2With:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT2_F(_v, _v, sq_len);
  return _mm_sqrt_ss(sq_len);
}

+ (SimdFloat4) Length3With:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT3_F(_v, _v, sq_len);
  return _mm_sqrt_ss(sq_len);
}

+ (SimdFloat4) Length4With:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT4_F(_v, _v, sq_len);
  return _mm_sqrt_ss(sq_len);
}

+ (SimdFloat4) Length2SqrWith:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT2_F(_v, _v, sq_len);
  return sq_len;
}

+ (SimdFloat4) Length3SqrWith:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT3_F(_v, _v, sq_len);
  return sq_len;
}

+ (SimdFloat4) Length4SqrWith:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT4_F(_v, _v, sq_len);
  return sq_len;
}

+ (SimdFloat4) Normalize2With:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT2_F(_v, _v, sq_len);
  assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
  const __m128 inv_len = _mm_div_ss([OZZFloat4 one], _mm_sqrt_ss(sq_len));
  const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
  const __m128 norm = _mm_mul_ps(_v, inv_lenxxxx);
  return _mm_movelh_ps(norm, _mm_movehl_ps(_v, _v));
}

+ (SimdFloat4) Normalize3With:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT3_F(_v, _v, sq_len);
  assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
  const __m128 inv_len = _mm_div_ss([OZZFloat4 one], _mm_sqrt_ss(sq_len));
  const __m128 vwxyz = OZZ_SHUFFLE_PS1(_v, _MM_SHUFFLE(0, 1, 2, 3));
  const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
  const __m128 normwxyz = _mm_move_ss(_mm_mul_ps(vwxyz, inv_lenxxxx), vwxyz);
  return OZZ_SHUFFLE_PS1(normwxyz, _MM_SHUFFLE(0, 1, 2, 3));
}

+ (SimdFloat4) Normalize4With:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT4_F(_v, _v, sq_len);
  assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
  const __m128 inv_len = _mm_div_ss([OZZFloat4 one], _mm_sqrt_ss(sq_len));
  const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
  return _mm_mul_ps(_v, inv_lenxxxx);
}

+ (SimdFloat4) NormalizeEst2With:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT2_F(_v, _v, sq_len);
  assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
  const __m128 inv_len = _mm_rsqrt_ss(sq_len);
  const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
  const __m128 norm = _mm_mul_ps(_v, inv_lenxxxx);
  return _mm_movelh_ps(norm, _mm_movehl_ps(_v, _v));
}

+ (SimdFloat4) NormalizeEst3With:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT3_F(_v, _v, sq_len);
  assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
  const __m128 inv_len = _mm_rsqrt_ss(sq_len);
  const __m128 vwxyz = OZZ_SHUFFLE_PS1(_v, _MM_SHUFFLE(0, 1, 2, 3));
  const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
  const __m128 normwxyz = _mm_move_ss(_mm_mul_ps(vwxyz, inv_lenxxxx), vwxyz);
  return OZZ_SHUFFLE_PS1(normwxyz, _MM_SHUFFLE(0, 1, 2, 3));
}

+ (SimdFloat4) NormalizeEst4With:(_SimdFloat4) _v {
  __m128 sq_len;
  OZZ_SSE_DOT4_F(_v, _v, sq_len);
  assert(_mm_cvtss_f32(sq_len) != 0.f && "_v is not normalizable");
  const __m128 inv_len = _mm_rsqrt_ss(sq_len);
  const __m128 inv_lenxxxx = OZZ_SSE_SPLAT_F(inv_len, 0);
  return _mm_mul_ps(_v, inv_lenxxxx);
}

+ (SimdInt4) IsNormalized2With:(_SimdFloat4) _v {
  const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceSq);
  const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceSq);
  __m128 dot;
  OZZ_SSE_DOT2_F(_v, _v, dot);
  __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
  return _mm_castps_si128(
      _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4) IsNormalized3With:(_SimdFloat4) _v {
  const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceSq);
  const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceSq);
  __m128 dot;
  OZZ_SSE_DOT3_F(_v, _v, dot);
  __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
  return _mm_castps_si128(
      _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4) IsNormalized4With:(_SimdFloat4) _v {
  const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceSq);
  const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceSq);
  __m128 dot;
  OZZ_SSE_DOT4_F(_v, _v, dot);
  __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
  return _mm_castps_si128(
      _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4) IsNormalizedEst2With:(_SimdFloat4) _v {
  const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceEstSq);
  const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceEstSq);
  __m128 dot;
  OZZ_SSE_DOT2_F(_v, _v, dot);
  __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
  return _mm_castps_si128(
      _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4) IsNormalizedEst3With:(_SimdFloat4) _v {
  const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceEstSq);
  const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceEstSq);
  __m128 dot;
  OZZ_SSE_DOT3_F(_v, _v, dot);
  __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
  return _mm_castps_si128(
      _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdInt4) IsNormalizedEst4With:(_SimdFloat4) _v {
  const __m128 max = _mm_set_ss(1.f + kNormalizationToleranceEstSq);
  const __m128 min = _mm_set_ss(1.f - kNormalizationToleranceEstSq);
  __m128 dot;
  OZZ_SSE_DOT4_F(_v, _v, dot);
  __m128 dotx000 = _mm_move_ss(_mm_setzero_ps(), dot);
  return _mm_castps_si128(
      _mm_and_ps(_mm_cmplt_ss(dotx000, max), _mm_cmpgt_ss(dotx000, min)));
}

+ (SimdFloat4) NormalizeSafe2With:(_SimdFloat4) _v :(_SimdFloat4) _safe {
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

+ (SimdFloat4) NormalizeSafe3With:(_SimdFloat4) _v :(_SimdFloat4) _safe {
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

+ (SimdFloat4) NormalizeSafe4With:(_SimdFloat4) _v :(_SimdFloat4) _safe {
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

+ (SimdFloat4) NormalizeSafeEst2With:(_SimdFloat4) _v :(_SimdFloat4) _safe {
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

+ (SimdFloat4) NormalizeSafeEst3With:(_SimdFloat4) _v :(_SimdFloat4) _safe {
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

+ (SimdFloat4) NormalizeSafeEst4With:(_SimdFloat4) _v :(_SimdFloat4) _safe {
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

+ (SimdFloat4) LerpWith:(_SimdFloat4) _a :(_SimdFloat4) _b :(_SimdFloat4) _alpha {
  return OZZ_MADD(_alpha, _mm_sub_ps(_b, _a), _a);
}

+ (SimdFloat4) MinWith:(_SimdFloat4) _a :(_SimdFloat4) _b {
  return _mm_min_ps(_a, _b);
}

+ (SimdFloat4) MaxWith:(_SimdFloat4) _a :(_SimdFloat4) _b {
  return _mm_max_ps(_a, _b);
}

+ (SimdFloat4) Min0With:(_SimdFloat4) _v {
  return _mm_min_ps(_mm_setzero_ps(), _v);
}

+ (SimdFloat4) Max0With:(_SimdFloat4) _v {
  return _mm_max_ps(_mm_setzero_ps(), _v);
}

+ (SimdFloat4) ClampWith:(_SimdFloat4) _a :(_SimdFloat4) _v :(_SimdFloat4) _b {
  return _mm_max_ps(_a, _mm_min_ps(_v, _b));
}

+ (SimdFloat4) SelectWith:(_SimdInt4) _b :(_SimdFloat4) _true :(_SimdFloat4) _false {
  return OZZ_SSE_SELECT_F(_b, _true, _false);
}

+ (SimdInt4) CmpEqWith:(_SimdFloat4) _a :(_SimdFloat4) _b {
  return _mm_castps_si128(_mm_cmpeq_ps(_a, _b));
}

+ (SimdInt4) CmpNeWith:(_SimdFloat4) _a :(_SimdFloat4) _b {
  return _mm_castps_si128(_mm_cmpneq_ps(_a, _b));
}

+ (SimdInt4) CmpLtWith:(_SimdFloat4) _a :(_SimdFloat4) _b {
  return _mm_castps_si128(_mm_cmplt_ps(_a, _b));
}

+ (SimdInt4) CmpLeWith:(_SimdFloat4) _a :(_SimdFloat4) _b {
  return _mm_castps_si128(_mm_cmple_ps(_a, _b));
}

+ (SimdInt4) CmpGtWith:(_SimdFloat4) _a :(_SimdFloat4) _b {
  return _mm_castps_si128(_mm_cmpgt_ps(_a, _b));
}

+ (SimdInt4) CmpGeWith:(_SimdFloat4) _a :(_SimdFloat4) _b {
  return _mm_castps_si128(_mm_cmpge_ps(_a, _b));
}

+ (SimdFloat4) AndWith:(_SimdFloat4) _a float4:(_SimdFloat4) _b {
  return _mm_and_ps(_a, _b);
}

+ (SimdFloat4) OrWith:(_SimdFloat4) _a float4:(_SimdFloat4) _b {
  return _mm_or_ps(_a, _b);
}

+ (SimdFloat4) XorWith:(_SimdFloat4) _a float4:(_SimdFloat4) _b {
  return _mm_xor_ps(_a, _b);
}

+ (SimdFloat4) AndWith:(_SimdFloat4) _a int4:(_SimdInt4) _b {
  return _mm_and_ps(_a, _mm_castsi128_ps(_b));
}

+ (SimdFloat4) AndNotWith:(_SimdFloat4) _a :(_SimdInt4) _b {
  return _mm_andnot_ps(_mm_castsi128_ps(_b), _a);
}

+ (SimdFloat4) OrWith:(_SimdFloat4) _a int4:(_SimdInt4) _b {
  return _mm_or_ps(_a, _mm_castsi128_ps(_b));
}

+ (SimdFloat4) XorWith:(_SimdFloat4) _a int4:(_SimdInt4) _b {
  return _mm_xor_ps(_a, _mm_castsi128_ps(_b));
}

+ (SimdFloat4) CosWith:(_SimdFloat4) _v {
  return _mm_set_ps(std::cos([OZZFloat4 GetWWith:_v]), std::cos([OZZFloat4 GetZWith:_v]),
                    std::cos([OZZFloat4 GetYWith:_v]), std::cos([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4) CosXWith:(_SimdFloat4) _v {
  return _mm_move_ss(_v, _mm_set_ps1(std::cos([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4) ACosWith:(_SimdFloat4) _v {
  return _mm_set_ps(std::acos([OZZFloat4 GetWWith:_v]), std::acos([OZZFloat4 GetZWith:_v]),
                    std::acos([OZZFloat4 GetYWith:_v]), std::acos([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4) ACosXWith:(_SimdFloat4) _v {
  return _mm_move_ss(_v, _mm_set_ps1(std::acos([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4) SinWith:(_SimdFloat4) _v {
  return _mm_set_ps(std::sin([OZZFloat4 GetWWith:_v]), std::sin([OZZFloat4 GetZWith:_v]), std::sin([OZZFloat4 GetYWith:_v]),
                    std::sin([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4) SinXWith:(_SimdFloat4) _v {
  return _mm_move_ss(_v, _mm_set_ps1(std::sin([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4) ASinWith:(_SimdFloat4) _v {
  return _mm_set_ps(std::asin([OZZFloat4 GetWWith:_v]), std::asin([OZZFloat4 GetZWith:_v]),
                    std::asin([OZZFloat4 GetYWith:_v]), std::asin([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4) ASinXWith:(_SimdFloat4) _v {
  return _mm_move_ss(_v, _mm_set_ps1(std::asin([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4) TanWith:(_SimdFloat4) _v {
  return _mm_set_ps(std::tan([OZZFloat4 GetWWith:_v]), std::tan([OZZFloat4 GetZWith:_v]),
                    std::tan([OZZFloat4 GetYWith:_v]), std::tan([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4) TanXWith:(_SimdFloat4) _v {
  return _mm_move_ss(_v, _mm_set_ps1(std::tan([OZZFloat4 GetXWith:_v])));
}

+ (SimdFloat4) ATanWith:(_SimdFloat4) _v {
  return _mm_set_ps(std::atan([OZZFloat4 GetWWith:_v]), std::atan([OZZFloat4 GetZWith:_v]),
                    std::atan([OZZFloat4 GetYWith:_v]), std::atan([OZZFloat4 GetXWith:_v]));
}

+ (SimdFloat4) ATanXWith:(_SimdFloat4) _v {
  return _mm_move_ss(_v, _mm_set_ps1(std::atan([OZZFloat4 GetXWith:_v])));
}


@end
