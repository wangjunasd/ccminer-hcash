#include <stdio.h>
#include <stdint.h>
#include <memory.h>

#include <cuda_helper.h>
#include <miner.h>


#define  F(x, y, z) (((x) ^ (y) ^ (z)))
#define FF(x, y, z) (((x) & (y)) | ((x) & (z)) | ((y) & (z)))
#define GG(x, y, z) ((z)  ^ ((x) & ((y) ^ (z))))

#define P0(x) x ^ ROTL32(x,  9) ^ ROTL32(x, 17)
#define P1(x) x ^ ROTL32(x, 15) ^ ROTL32(x, 23)

__device__
void sm3_compress1(uint32_t digest[8], const uint32_t block[16]){
	uint32_t tt1, tt2, i, ss1, ss2, x, y;
	uint32_t w[68];
	uint32_t a = digest[0];
	uint32_t b = digest[1];
	uint32_t c = digest[2];
	uint32_t d = digest[3];
	uint32_t e = digest[4];
	uint32_t f = digest[5];
	uint32_t g = digest[6];
	uint32_t h = digest[7];

#pragma unroll 16
	for (i = 0; i<16; i++) {
		w[i] = cuda_swab32(block[i]);
	}
#pragma unroll 52
	for (i = 16; i<68; i++) {
		x = ROTL32(w[i - 3], 15);
		y = ROTL32(w[i - 13], 7);

		x ^= w[i - 16];
		x ^= w[i - 9];
		y ^= w[i - 6];

		w[i] = P1(x) ^ y;
	}
#pragma unroll 16
	for (i = 0; i < 16; i++){

		ss2 = ROTL32(a, 12);
		ss1 = ROTL32(ss2 + e + ROTL32(0x79cc4519, i), 7);
		ss2 ^= ss1;

		tt1 = d + ss2 + (w[i] ^ w[i + 4]) + F(a, b, c);
		tt2 = h + ss1 + w[i] + F(e, f, g);

		d = c;
		c = ROTL32(b, 9);
		b = a;
		a = tt1;
		h = g;
		g = ROTL32(f, 19);
		f = e;
		e = P0(tt2);

	}
#pragma unroll 48
	for (i = 16; i < 64; i++){
		ss2 = ROTL32(a, 12);
		ss1 = ROTL32(ss2 + e + ROTL32(0x7a879d8a, i), 7);
		ss2 ^= ss1;

		tt1 = d + ss2 + (w[i] ^ w[i + 4]) + FF(a, b, c);
		tt2 = h + ss1 + w[i] + GG(e, f, g);

		d = c;
		c = ROTL32(b, 9);
		b = a;
		a = tt1;
		h = g;
		g = ROTL32(f, 19);
		f = e;
		e = P0(tt2);

	}

	digest[0] ^= a;
	digest[1] ^= b;
	digest[2] ^= c;
	digest[3] ^= d;
	digest[4] ^= e;
	digest[5] ^= f;
	digest[6] ^= g;
	digest[7] ^= h;
}

__device__
void sm3_compress2(uint32_t digest[8]){
	uint32_t tt1, tt2, i, ss1, ss2;
	uint32_t w[68] = { 0x80000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x200, 0x80404000, 0x0, 0x1008080, 0x10005000, 0x0, 0x2002a0, 0xac545c04, 0x0, 0x9582a39, 0xa0003000, 0x0, 0x200280, 0xa4515804, 0x20200040, 0x51609838, 0x30005701, 0xa0002000, 0x8200aa, 0x6ad525d0, 0xa0e0216, 0xb0f52042, 0xfa7073b0, 0x20000000, 0x8200a8, 0x7a542590, 0x22a20044, 0xd5d6ebd2, 0x82005771, 0x8a202240, 0xb42826aa, 0xeaf84e59, 0x4898eaf9, 0x8207283d, 0xee6775fa, 0xa3e0e0a0, 0x8828488a, 0x23b45a5d, 0x628a22c4, 0x8d6d0615, 0x38300a7e, 0xe96260e5, 0x2b60c020, 0x502ed531, 0x9e878cb9, 0x218c38f8, 0xdcae3cb7, 0x2a3e0e0a, 0xe9e0c461, 0x8c3e3831, 0x44aaa228, 0xdc60a38b, 0x518300f7 };
	uint32_t a = digest[0];
	uint32_t b = digest[1];
	uint32_t c = digest[2];
	uint32_t d = digest[3];
	uint32_t e = digest[4];
	uint32_t f = digest[5];
	uint32_t g = digest[6];
	uint32_t h = digest[7];

#pragma unroll 16
	for (i = 0; i < 16; i++){

		ss2 = ROTL32(a, 12);
		ss1 = ROTL32(ss2 + e + ROTL32(0x79cc4519, i), 7);
		ss2 ^= ss1;

		tt1 = d + ss2 + (w[i] ^ w[i + 4]) + F(a, b, c);
		tt2 = h + ss1 + w[i] + F(e, f, g);

		d = c;
		c = ROTL32(b, 9);
		b = a;
		a = tt1;
		h = g;
		g = ROTL32(f, 19);
		f = e;
		e = P0(tt2);

	}
#pragma unroll 48
	for (i = 16; i < 64;i++){
		ss2 = ROTL32(a, 12);
		ss1 = ROTL32(ss2 + e + ROTL32(0x7a879d8a, i), 7);
		ss2 ^= ss1;

		tt1 = d + ss2 + (w[i] ^ w[i + 4]) + FF(a, b, c);
		tt2 = h + ss1 + w[i] + GG(e, f, g);

		d = c;
		c = ROTL32(b, 9);
		b = a;
		a = tt1;
		h = g;
		g = ROTL32(f, 19);
		f = e;
		e = P0(tt2);

	}

	digest[0] ^= a;
	digest[1] ^= b;
	digest[2] ^= c;
	digest[3] ^= d;
	digest[4] ^= e;
	digest[5] ^= f;
	digest[6] ^= g;
	digest[7] ^= h;

}


/***************************************************/
// GPU Hash Function
__global__ void x14_sm3_gpu_hash_64(uint32_t threads, uint32_t *g_hash)
{
	const uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);

	if (thread < threads)
	{
		

		uint32_t *Hash = &g_hash[thread << 4];

		//__syncthreads();

		uint32_t digest[8] = {
			0x7380166F, 0x4914B2B9, 0x172442D7, 0xDA8A0600, 0xA96F30BC, 0x163138AA, 0xE38DEE4D, 0xB0FB0E4E
		};

		sm3_compress1(digest, Hash);

		sm3_compress2(digest);

#pragma unroll 8
		for (int i = 0; i < 8; i++)
			Hash[i] = cuda_swab32(digest[i]);
//#pragma unroll 8
//		for (int i = 8; i < 16; i++)
//			Hash[i] = 0;

	}

}

__host__ void x14_sm3_cpu_hash_64(int thr_id, uint32_t threads, uint32_t *d_hash)
{

	const uint32_t threadsperblock = 128;

	dim3 grid((threads + threadsperblock - 1) / threadsperblock);
	dim3 block(threadsperblock);

	x14_sm3_gpu_hash_64 << <grid, block >> >(threads, d_hash);
}