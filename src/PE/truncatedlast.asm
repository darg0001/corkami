; a PE with last section truncated

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,     dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 3 * SECTIONALIGN ; <=
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

%include 'dd_imports.inc'

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 2 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd SECTION1SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 2 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_READ
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

Section0Start:

%include 'code_printf.inc'

%include 'imports_printfexitprocess.inc'

SECTION0SIZE EQU $ - Section0Start

_d
times 0A0h db 0
db 'this will be in memory even if physically and virtually (but before rounding up) out of the section', 0

align FILEALIGN, db 0

section nobits vstart=IMAGEBASE + 2 * SECTIONALIGN

Section1Start:
Msg db " * last section truncated", 0ah, 0
SECTION1SIZE equ $ - Section1Start
