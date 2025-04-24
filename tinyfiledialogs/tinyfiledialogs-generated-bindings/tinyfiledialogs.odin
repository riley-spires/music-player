/* SPDX-License-Identifier: Zlib
Copyright (c) 2014 - 2024 Guillaume Vareille http://ysengrin.com
____________________________________________________________________
|                                                                    |
| 100% compatible C C++  ->  You can rename tinfiledialogs.c as .cpp |
|____________________________________________________________________|

********* TINY FILE DIALOGS OFFICIAL WEBSITE IS ON SOURCEFORGE *********
_________
/         \ tinyfiledialogs.h v3.19.1 [Jan 27, 2025]
|tiny file| Unique header file created [November 9, 2014]
| dialogs |
\____  ___/ http://tinyfiledialogs.sourceforge.net
\|     git clone http://git.code.sf.net/p/tinyfiledialogs/code tinyfd
____________________________________________
|                                            |
|   email: tinyfiledialogs at ysengrin.com   |
|____________________________________________|
________________________________________________________________________________
|  ____________________________________________________________________________  |
| |                                                                            | |
| |  - in tinyfiledialogs, char is UTF-8 by default (since v3.6)               | |
| |                                                                            | |
| | on windows:                                                                | |
| |  - for UTF-16, use the wchar_t functions at the bottom of the header file  | |
| |                                                                            | |
| |  - _wfopen() requires wchar_t                                              | |
| |  - fopen() uses char but expects ASCII or MBCS (not UTF-8)                 | |
| |  - if you want char to be MBCS: set tinyfd_winUtf8 to 0                    | |
| |                                                                            | |
| |  - alternatively, tinyfiledialogs provides                                 | |
| |                        functions to convert between UTF-8, UTF-16 and MBCS | |
| |____________________________________________________________________________| |
|________________________________________________________________________________|

If you like tinyfiledialogs, please upvote my stackoverflow answer
https://stackoverflow.com/a/47651444

- License -
This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.
Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:
1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software.  If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

__________________________________________
|  ______________________________________  |
| |                                      | |
| | DO NOT USE USER INPUT IN THE DIALOGS | |
| |______________________________________| |
|__________________________________________|
*/
package tinyfiledialogs

foreign import lib "../tinyfiledialogs.a"
import "core:c"

_ :: c



@(default_calling_convention="c", link_prefix="")
foreign lib {
	/************* 3 funtions for C# (you don't need this in C or C++) : */
	tinyfd_getGlobalChar :: proc(aCharVariableName: cstring) -> cstring ---
	tinyfd_getGlobalInt  :: proc(aIntVariableName: cstring) -> i32 ---
	tinyfd_setGlobalInt  :: proc(aIntVariableName: cstring, aValue: i32) -> i32 ---

	/* if you pass "tinyfd_query" as aTitle,
	the functions will not display the dialogs
	but will return 0 for console mode, 1 for graphic mode.
	tinyfd_response is then filled with the retain solution.
	possible values for tinyfd_response are (all lowercase)
	for graphic mode:
	windows_wchar windows applescript kdialog zenity zenity3 yad matedialog
	shellementary qarma python2-tkinter python3-tkinter python-dbus
	perl-dbus gxmessage gmessage xmessage xdialog gdialog dunst
	for console mode:
	dialog whiptail basicinput no_solution */
	tinyfd_beep        :: proc() ---
	tinyfd_notifyPopup :: proc(aTitle: cstring, aMessage: cstring, aIconType: cstring) -> i32 ---

	/* return has only meaning for tinyfd_query */
	tinyfd_messageBox :: proc(aTitle: cstring, aMessage: cstring, aDialogType: cstring, aIconType: cstring, aDefaultButton: i32) -> i32 ---

	/* 0 for cancel/no , 1 for ok/yes , 2 for no in yesnocancel */
	tinyfd_inputBox :: proc(aTitle: cstring, aMessage: cstring, aDefaultInput: cstring) -> cstring ---

	/* returns NULL on cancel */
	tinyfd_saveFileDialog :: proc(aTitle: cstring, aDefaultPathAndOrFile: cstring, aNumOfFilterPatterns: i32, aFilterPatterns: [^]cstring, aSingleFilterDescription: cstring) -> cstring ---

	/* returns NULL on cancel */
	tinyfd_openFileDialog :: proc(aTitle: cstring, aDefaultPathAndOrFile: cstring, aNumOfFilterPatterns: i32, aFilterPatterns: [^]cstring, aSingleFilterDescription: cstring, aAllowMultipleSelects: i32) -> cstring ---

	/* in case of multiple files, the separator is | */
	/* returns NULL on cancel */
	tinyfd_selectFolderDialog :: proc(aTitle: cstring, aDefaultPath: cstring) -> cstring ---

	/* returns NULL on cancel */
	tinyfd_colorChooser :: proc(aTitle: cstring, aDefaultHexRGB: cstring, aDefaultRGB: ^u8, aoResultRGB: ^u8) -> cstring ---
}
