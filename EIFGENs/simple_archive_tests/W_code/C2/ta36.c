/*
 * Code for class TAR_CONST
 */

#include "eif_eiffel.h"
#include "../E1/estructure.h"


#ifdef __cplusplus
extern "C" {
#endif

extern EIF_TYPED_VALUE F36_783(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_784(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_785(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_786(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_787(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_788(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_789(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_790(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_791(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_792(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_793(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_794(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_795(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_796(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_797(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_798(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_799(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_800(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_801(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_802(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_803(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_804(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_805(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_806(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_807(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_808(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_809(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_810(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_811(EIF_REFERENCE);
extern EIF_TYPED_VALUE F36_812(EIF_REFERENCE);
extern void EIF_Minit36(void);

#ifdef __cplusplus
}
#endif


#ifdef __cplusplus
extern "C" {
#endif


#ifdef __cplusplus
}
#endif


#ifdef __cplusplus
extern "C" {
#endif

/* {TAR_CONST}.setuid_mask */
EIF_TYPED_VALUE F36_783 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 2048U);
	return r;
}

/* {TAR_CONST}.setgid_mask */
EIF_TYPED_VALUE F36_784 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 1024U);
	return r;
}

/* {TAR_CONST}.uread_mask */
EIF_TYPED_VALUE F36_785 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 256U);
	return r;
}

/* {TAR_CONST}.uwrite_mask */
EIF_TYPED_VALUE F36_786 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 128U);
	return r;
}

/* {TAR_CONST}.uexec_mask */
EIF_TYPED_VALUE F36_787 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 64U);
	return r;
}

/* {TAR_CONST}.gread_mask */
EIF_TYPED_VALUE F36_788 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 32U);
	return r;
}

/* {TAR_CONST}.gwrite_mask */
EIF_TYPED_VALUE F36_789 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 16U);
	return r;
}

/* {TAR_CONST}.gexec_mask */
EIF_TYPED_VALUE F36_790 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 8U);
	return r;
}

/* {TAR_CONST}.oread_mask */
EIF_TYPED_VALUE F36_791 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 4U);
	return r;
}

/* {TAR_CONST}.owrite_mask */
EIF_TYPED_VALUE F36_792 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 2U);
	return r;
}

/* {TAR_CONST}.oexec_mask */
EIF_TYPED_VALUE F36_793 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 1U);
	return r;
}

/* {TAR_CONST}.tar_typeflag_regular_file */
EIF_TYPED_VALUE F36_794 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) '0';
	return r;
}

/* {TAR_CONST}.tar_typeflag_regular_file_old */
EIF_TYPED_VALUE F36_795 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) '\000';
	return r;
}

/* {TAR_CONST}.tar_typeflag_hardlink */
EIF_TYPED_VALUE F36_796 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) '1';
	return r;
}

/* {TAR_CONST}.tar_typeflag_symlink */
EIF_TYPED_VALUE F36_797 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) '2';
	return r;
}

/* {TAR_CONST}.tar_typeflag_character_special */
EIF_TYPED_VALUE F36_798 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) '3';
	return r;
}

/* {TAR_CONST}.tar_typeflag_block_special */
EIF_TYPED_VALUE F36_799 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) '4';
	return r;
}

/* {TAR_CONST}.tar_typeflag_directory */
EIF_TYPED_VALUE F36_800 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) '5';
	return r;
}

/* {TAR_CONST}.tar_typeflag_fifo */
EIF_TYPED_VALUE F36_801 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) '6';
	return r;
}

/* {TAR_CONST}.tar_typeflag_contiguous */
EIF_TYPED_VALUE F36_802 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) '7';
	return r;
}

/* {TAR_CONST}.tar_typeflag_pax_extended */
EIF_TYPED_VALUE F36_803 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) 'x';
	return r;
}

/* {TAR_CONST}.tar_typeflag_pax_global */
EIF_TYPED_VALUE F36_804 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_CHAR8;
	r.it_c1 = (EIF_CHARACTER_8) (EIF_CHARACTER_8) 'g';
	return r;
}

/* {TAR_CONST}.tar_header_only_typeflags */
RTOID (F36_805)


EIF_TYPED_VALUE F36_805 (EIF_REFERENCE Current)
{
	GTCX
	RTOTC (F36_805,867,RTMS_EX_H("123456",6,955781430));
}

/* {TAR_CONST}.tar_block_size */
EIF_TYPED_VALUE F36_806 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_INT32;
	r.it_i4 = (EIF_INTEGER_32) ((EIF_INTEGER_32) 512L);
	return r;
}

/* {TAR_CONST}.ustar_magic */
RTOID (F36_807)


EIF_TYPED_VALUE F36_807 (EIF_REFERENCE Current)
{
	GTCX
	RTOTC (F36_807,869,RTMS_EX_H("ustar",5,1937905522));
}

/* {TAR_CONST}.ustar_version */
RTOID (F36_808)


EIF_TYPED_VALUE F36_808 (EIF_REFERENCE Current)
{
	GTCX
	RTOTC (F36_808,870,RTMS_EX_H("00",2,12336));
}

/* {TAR_CONST}.pax_header_filename */
RTOID (F36_809)


EIF_TYPED_VALUE F36_809 (EIF_REFERENCE Current)
{
	GTCX
	RTOTC (F36_809,871,RTMS_EX_H("./PaxHeader",11,1669199474));
}

/* {TAR_CONST}.pax_header_uid */
EIF_TYPED_VALUE F36_810 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT32;
	r.it_n4 = (EIF_NATURAL_32) ((EIF_NATURAL_32) 0U);
	return r;
}

/* {TAR_CONST}.pax_header_gid */
EIF_TYPED_VALUE F36_811 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT32;
	r.it_n4 = (EIF_NATURAL_32) ((EIF_NATURAL_32) 0U);
	return r;
}

/* {TAR_CONST}.pax_header_mode */
EIF_TYPED_VALUE F36_812 (EIF_REFERENCE Current)
{
	EIF_TYPED_VALUE r;
	r.type = SK_UINT16;
	r.it_n2 = (EIF_NATURAL_16) ((EIF_NATURAL_16) 420U);
	return r;
}

void EIF_Minit36 (void)
{
	GTCX
	RTOTS (805,F36_805)
	RTOTS (807,F36_807)
	RTOTS (808,F36_808)
	RTOTS (809,F36_809)
}


#ifdef __cplusplus
}
#endif
