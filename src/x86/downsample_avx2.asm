; Copyright (c) 2022, The rav1e contributors. All rights reserved
;
; This source code is subject to the terms of the BSD 2 Clause License and
; the Alliance for Open Media Patent License 1.0. If the BSD 2 Clause License
; was not distributed with this source code in the LICENSE file, you can
; obtain it at www.aomedia.org/license/software. If the Alliance for Open
; Media Patent License 1.0 was not distributed with this source code in the
; PATENTS file, you can obtain it at www.aomedia.org/license/patent.

%include "config.asm"
%include "ext/x86/x86inc.asm"

SECTION .text

%if ARCH_X86_64

pw_m8192:      times 8 dw -8192

INIT_YMM avx2
; len is a multiple of 64
cglobal box_2x2_8bpc, 4, 7, 0, dst, s1, s2, len, cnt
    xor          cntq, cntq
    vpbroadcastd m5, [pw_m8192] ; -8192
    pcmpeqb      m4, m4         ; -1
.inner:
    mova         m0, [s1q+32*0+cntq]
    mova         m2, [s2q+32*0+cntq]
    mova         m1, [s1q+32*1+cntq]
    mova         m3, [s2q+32*1+cntq]
    ; needs to be added with 16 bit precision
    pmaddubsw    m0, m4
    pmaddubsw    m2, m4
    pmaddubsw    m1, m4
    pmaddubsw    m3, m4
    paddw        m0, m2
    paddw        m1, m3
    pmulhrsw     m0, m5
    pmulhrsw     m1, m5
    packuswb     m0, m1
    vpermq       m0, m0, q3120
    mova         [dstq], m0
    add          cntq, 64
    cmp          cntq, lenq
    jne          .inner
    RET

%endif ; ARCH_X86_64
