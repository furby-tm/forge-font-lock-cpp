;;; forge-font-lock-cpp.el --- Font-locking for "Modern C++"  -*- lexical-binding: t; -*-

;; Copyright © 2020, by The Forge

;; Author: Tyler Furby <tyler@tylerfurby.com>
;; URL: https://github.com/tyler-furby/forge-font-lock-cpp
;; Version: 1.0.0
;; Created: 12 May 2020
;; Keywords: languages, c++, cpp, font-lock

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Syntax highlighting support for "Modern C++" - until C++20 and
;; Technical Specification. This package aims to provide a simple
;; highlight of the C++ language without dependency.

;; It is recommended to use it in addition with the c++-mode major
;; mode for extra highlighting (user defined types, functions, etc.)
;; and indentation.

;; Melpa: [M-x] package-install [RET] forge-font-lock-cpp [RET]
;; In your init Emacs file add:
;;     (add-hook 'c++-mode-hook #'forge-font-lock-c++-mode)
;; or:
;;     (forge-font-lock-c++-mode t)

;; For the current buffer, the minor-mode can be turned on/off via the
;; command:
;;     [M-x] forge-font-lock-c++-mode [RET]

;; More documentation:
;; https://github.com/tyler-furby/forge-font-lock-cpp/blob/master/README.md

;; Feedback is welcome!

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(defgroup forge-font-lock-c++ nil
  "Provides font-locking as a Minor Mode for Modern C++"
  :group 'faces)

(eval-and-compile
  (defun forge-c++-string-lenght< (a b) (< (length a) (length b)))
  (defun forge-c++-string-lenght> (a b) (not (forge-c++-string-lenght< a b))))

(defcustom forge-c++-types
  (eval-when-compile
    (sort '("bool" "char" "char8_t" "char16_t" "char32_t" "double" "float" "int" "long" "short" "signed" "unsigned" "void" "wchar_t")
          'forge-c++-string-lenght>))
  "List of C++ types. See doc:
http://en.cppreference.com/w/cpp/language/types"
  :type '(choice (const :tag "Disabled" nil)
                 (repeat string))
  :group 'forge-font-lock-c++)

(defcustom forge-c++-preprocessors
  (eval-when-compile
    (sort '("#define" "#defined" "#elif" "#else" "#endif" "#error" "#if" "#ifdef" "#ifndef" "#include" "#line" "#pragma STDC CX_LIMITED_RANGE" "#pragma STDC FENV_ACCESS" "#pragma STDC FP_CONTRACT" "#pragma once" "#pragma pack" "#pragma" "#undef" "_Pragma" "__DATE__" "__FILE__" "__LINE__" "__STDCPP_STRICT_POINTER_SAFETY__" "__STDCPP_THREADS__" "__STDC_HOSTED__" "__STDC_ISO_10646__" "__STDC_MB_MIGHT_NEQ_WC__" "__STDC_VERSION__" "__STDC__" "__TIME__" "__VA_AR_GS__" "__cplusplus" "__has_include" "__has_cpp_attribute")
          'forge-c++-string-lenght>))
  "List of C++ preprocessor words. See doc:
http://en.cppreference.com/w/cpp/keyword and
http://en.cppreference.com/w/cpp/preprocessor"
  :type '(choice (const :tag "Disabled" nil)
                 (repeat string))
  :group 'forge-font-lock-c++)

(defcustom forge-c++-keywords
  (eval-when-compile
    (sort '("alignas" "alignof" "and" "and_eq" "asm" "atomic_cancel" "atomic_commit" "atomic_noexcept" "audit" "auto" "axiom" "bitand" "bitor" "break" "case" "catch" "class" "compl" "concept" "const" "constexpr" "consteval" "const_cast" "continue" "co_await" "co_return" "co_yield" "decltype" "default" "delete" "do" "dynamic_cast" "else" "enum" "explicit" "export" "extern" "final" "for" "friend" "goto" "if" "import" "inline" "module" "mutable" "namespace" "new" "noexcept" "not" "not_eq" "operator" "or" "or_eq" "override" "private" "protected" "public" "register" "reinterpret_cast" "requires" "return" "sizeof" "static" "static_assert" "static_cast" "switch" "synchronized" "template" "this" "thread_local" "throw" "transaction_safe" "transaction_safe_dynamic" "try" "typedef" "typeid" "typename" "union" "using" "virtual" "volatile" "while" "xor" "xor_eq")
          'forge-c++-string-lenght>))
  "List of C++ keywords. See doc:
http://en.cppreference.com/w/cpp/keyword"
  :type '(choice (const :tag "Disabled" nil)
                 (repeat string))
  :group 'forge-font-lock-c++)

(defcustom forge-c++-attributes
  (eval-when-compile
    (sort '("carries_dependency" "deprecated" "fallthrough" "maybe_unused" "nodiscard" "noreturn" "optimize_for_synchronized" "likely" "unlikely" "no_unique_address" "expects" "ensures" "assert")
          'forge-c++-string-lenght>))
  "List of C++ attributes. See doc:
http://en.cppreference.com/w/cpp/language/attributes"
  :type '(choice (const :tag "Disabled" nil)
                 (repeat string))
  :group 'forge-font-lock-c++)

(defcustom forge-c++-operators
  (eval-when-compile
    (sort '("...")
          'forge-c++-string-lenght>))
  "List of C++ assignment operators. Left Intentionally almost
empty. The user will choose what should be font-locked. By
default I want to avoid a 'christmas tree' C++ code. For more
information, see doc:
http://en.cppreference.com/w/cpp/language/operators"
  :type '(choice (const :tag "Disabled" nil)
                 (repeat string))
  :group 'forge-font-lock-c++)

(defvar forge-font-lock-c++-keywords nil)

(defun forge-c++-generate-font-lock-keywords ()
  (let ((types-regexp (regexp-opt forge-c++-types 'symbols))
        (preprocessors-regexp (regexp-opt forge-c++-preprocessors))
        (keywords-regexp (regexp-opt forge-c++-keywords 'words))
        (attributes-regexp
         (concat "\\[\\[\\(" (regexp-opt forge-c++-attributes 'words) "\\).*\\]\\]"))
        (operators-regexp (regexp-opt forge-c++-operators)))
    (setq forge-font-lock-c++-keywords
          `(
            ;; Note: order below matters, because once colored, that part
            ;; won't change. In general, longer words first
            (,types-regexp (0 font-lock-type-face))
            (,preprocessors-regexp (0 font-lock-preprocessor-face))
            (,attributes-regexp (1 font-lock-constant-face))
            (,operators-regexp (0 font-lock-function-name-face))
            (,keywords-regexp (0 font-lock-keyword-face))))))

(defcustom forge-c++-literal-boolean
  t
  "Enable font-lock for boolean literals. For more information,
see documentation:
http://en.cppreference.com/w/cpp/language/bool_literal"
  :type 'boolean
  :group 'forge-font-lock-c++)

(defvar forge-font-lock-c++-literal-boolean nil)

(defun forge-c++-generate-font-lock-literal-boolean ()
  (let ((literal-boolean-regexp (regexp-opt
                                 (eval-when-compile (sort '("false" "true") 'forge-c++-string-lenght>))
                                 'words)))
    (setq forge-font-lock-c++-literal-boolean
          `(
            ;; Note: order below matters, because once colored, that part
            ;; won't change. In general, longer words first
            (,literal-boolean-regexp (0 font-lock-constant-face))))))

(defcustom forge-c++-literal-integer
  t
  "Enable font-lock for integer literals. For more information,
see documentation:
http://en.cppreference.com/w/cpp/language/integer_literal"
  :type 'boolean
  :group 'forge-font-lock-c++)

(defvar forge-font-lock-c++-literal-integer nil)

(defun forge-c++-generate-font-lock-literal-integer ()
  (eval-when-compile
    (let* ((integer-suffix-regexp (regexp-opt (sort '("ull" "LLu" "LLU" "llu" "llU" "uLL" "ULL" "Ull" "ll" "LL" "ul" "uL" "Ul" "UL" "lu" "lU" "LU" "Lu" "u" "U" "l" "L") 'forge-c++-string-lenght>)))
           (not-alpha-numeric-regexp "[^0-9a-zA-Z'\\\._]")
           (literal-binary-regexp (concat not-alpha-numeric-regexp "\\(0[bB]\\)\\([01']+\\)\\(" integer-suffix-regexp "?\\)"))
           (literal-octal-regexp (concat not-alpha-numeric-regexp "\\(0\\)\\([0-7']+\\)\\(" integer-suffix-regexp "?\\)"))
           (literal-hex-regexp (concat not-alpha-numeric-regexp "\\(0[xX]\\)\\([0-9a-fA-F']+\\)\\(" integer-suffix-regexp "?\\)"))
           (literal-dec-regexp (concat not-alpha-numeric-regexp "\\([1-9][0-9']*\\)\\(" integer-suffix-regexp "\\)")))
      (setq forge-font-lock-c++-literal-integer
            `(
              ;; Note: order below matters, because once colored, that part
              ;; won't change. In general, longer words first
              (,literal-binary-regexp (1 font-lock-keyword-face)
                                      (2 font-lock-constant-face)
                                      (3 font-lock-keyword-face))
              (,literal-octal-regexp (1 font-lock-keyword-face)
                                     (2 font-lock-constant-face)
                                     (3 font-lock-keyword-face))
              (,literal-hex-regexp (1 font-lock-keyword-face)
                                   (2 font-lock-constant-face)
                                   (3 font-lock-keyword-face))
              (,literal-dec-regexp (1 font-lock-constant-face)
                                   (2 font-lock-keyword-face)))))))

(defcustom forge-c++-literal-null-pointer
  t
  "Enable font-lock for null pointer literals. For more information,
see documentation:
http://en.cppreference.com/w/cpp/language/nullptr"
  :type 'boolean
  :group 'forge-font-lock-c++)

(defvar forge-font-lock-c++-literal-null-pointer nil)

(defun forge-c++-generate-font-lock-literal-null-pointer ()
  (let ((literal-null-pointer-regexp (regexp-opt
                                      (eval-when-compile (sort '("nullptr") 'forge-c++-string-lenght>))
                                      'words)))
    (setq forge-font-lock-c++-literal-null-pointer
          `(
            ;; Note: order below matters, because once colored, that part
            ;; won't change. In general, longer words first
            (,literal-null-pointer-regexp (0 font-lock-constant-face))))))

(defcustom forge-c++-literal-string
  t
  "Enable font-lock for string literals. For more information,
see documentation:
http://en.cppreference.com/w/cpp/language/string_literal"
  :type 'boolean
  :group 'forge-font-lock-c++)

(defvar forge-font-lock-c++-literal-string nil)

(defun forge-c++-generate-font-lock-literal-string ()
  (eval-when-compile
    (let* ((simple-string-regexp "\"[^\"]*\"")
           (raw "R")
           (prefix-regexp
            (regexp-opt (sort '("L" "u8" "u" "U") 'forge-c++-string-lenght>)))
           (literal-string-regexp
            (concat "\\(" prefix-regexp "?\\)\\(" simple-string-regexp "\\)\\(s?\\)"))
           (delimiter-group-regexp "\\([^\\s-\\\\()]\\{1,16\\}\\)")
           (raw-delimiter-literal-string-regexp
            (concat "\\(" prefix-regexp "?" raw
                    "\"" delimiter-group-regexp "(\\)"
                    "\\(\\(.\\|\n\\)*?\\)"
                    "\\()\\2\"s?\\)"))
           (raw-literal-string-regexp
            (concat "\\(" prefix-regexp "?" raw "\"(\\)"
                    "\\(\\(.\\|\n\\)*?\\)"
                    "\\()\"s?\\)")))
      (setq forge-font-lock-c++-literal-string
            `(
              ;; Note: order below matters, because once colored, that part
              ;; won't change. In general, longer words first
              (,raw-delimiter-literal-string-regexp (1 font-lock-constant-face)
                                                    (3 font-lock-string-face)
                                                    (5 font-lock-constant-face))
              (,raw-literal-string-regexp (1 font-lock-constant-face)
                                          (2 font-lock-string-face)
                                          (4 font-lock-constant-face))
              (,literal-string-regexp (1 font-lock-constant-face)
                                      (2 font-lock-string-face)
                                      (3 font-lock-constant-face)))))))

(defcustom forge-c++-stl-cstdint
  t
  "Enable font-lock for header <cstdint>. For more information,
see documentation:
http://en.cppreference.com/w/cpp/header/cstdint"
  :type 'boolean
  :group 'forge-font-lock-c++)

(defvar forge-font-lock-c++-stl-cstdint nil)

(defun forge-c++-generate-font-lock-stl-cstdint ()
  (let ((stl-cstdint-types (regexp-opt
                            (eval-when-compile
                              (sort (mapcar (function (lambda (x) (concat "std::" x)))
                                            '("int8_t" "int16_t" "int32_t" "int64_t" "int_fast8_t" "int_fast16_t" "int_fast32_t" "int_fast64_t" "int_least8_t" "int_least16_t" "int_least32_t" "int_least64_t" "intmax_t" "intptr_t" "uint8_t" "uint16_t" "uint32_t" "uint64_t" "uint_fast8_t" "uint_fast16_t" "uint_fast32_t" "uint_fast64_t" "uint_least8_t" "uint_least16_t" "uint_least32_t" "uint_least64_t" "uintmax_t" "uintptr_t"))
                                    'forge-c++-string-lenght>))
                            'symbols))
        (stl-cstdint-macro (regexp-opt
                            (eval-when-compile
                              (sort '("INT8_MIN" "INT16_MIN" "INT32_MIN" "INT64_MIN" "INT_FAST8_MIN" "INT_FAST16_MIN" "INT_FAST32_MIN" "INT_FAST64_MIN" "INT_LEAST8_MIN" "INT_LEAST16_MIN" "INT_LEAST32_MIN" "INT_LEAST64_MIN" "INTPTR_MIN" "INTMAX_MIN" "INT8_MAX" "INT16_MAX" "INT32_MAX" "INT64_MAX" "INT_FAST8_MAX" "INT_FAST16_MAX" "INT_FAST32_MAX" "INT_FAST64_MAX" "INT_LEAST8_MAX" "INT_LEAST16_MAX" "INT_LEAST32_MAX" "INT_LEAST64_MAX" "INTPTR_MAX" "INTMAX_MAX" "UINT8_MAX" "UINT16_MAX" "UINT32_MAX" "UINT64_MAX" "UINT_FAST8_MAX" "UINT_FAST16_MAX" "UINT_FAST32_MAX" "UINT_FAST64_MAX" "UINT_LEAST8_MAX" "UINT_LEAST16_MAX" "UINT_LEAST32_MAX" "UINT_LEAST64_MAX" "UINTPTR_MAX" "UINTMAX_MAX" "INT8_C" "INT16_C" "INT32_C" "INT64_C" "INTMAX_C" "UINT8_C" "UINT16_C" "UINT32_C" "UINT64_C" "UINTMAX_C" "PTRDIFF_MIN" "PTRDIFF_MAX" "SIZE_MAX" "SIG_ATOMIC_MIN" "SIG_ATOMIC_MAX" "WCHAR_MIN" "WCHAR_MAX" "WINT_MIN" "WINT_MAX")
                                    'forge-c++-string-lenght>))
                            'symbols)))
    (setq forge-font-lock-c++-stl-cstdint
          `(
            ;; Note: order below matters, because once colored, that part
            ;; won't change. In general, longer words first
            (,stl-cstdint-types (0 font-lock-type-face))
            (,stl-cstdint-macro (0 font-lock-preprocessor-face))))))

(defun forge-font-lock-c++-add-keywords (&optional mode)
  "Install keywords into major MODE, or into current buffer if nil."
  (font-lock-add-keywords mode (forge-c++-generate-font-lock-keywords) nil)
  (when forge-c++-literal-boolean
    (font-lock-add-keywords mode (forge-c++-generate-font-lock-literal-boolean) nil))
  (when forge-c++-literal-integer
    (font-lock-add-keywords mode (forge-c++-generate-font-lock-literal-integer) nil))
  (when forge-c++-literal-null-pointer
    (font-lock-add-keywords mode (forge-c++-generate-font-lock-literal-null-pointer) nil))
  (when forge-c++-literal-string
    (font-lock-add-keywords mode (forge-c++-generate-font-lock-literal-string) nil))
  (when forge-c++-stl-cstdint
    (font-lock-add-keywords mode (forge-c++-generate-font-lock-stl-cstdint) nil)))

(defun forge-font-lock-c++-remove-keywords (&optional mode)
  "Remove keywords from major MODE, or from current buffer if nil."
  (font-lock-remove-keywords mode forge-font-lock-c++-keywords)
  (when forge-c++-literal-boolean
    (font-lock-remove-keywords mode forge-font-lock-c++-literal-boolean))
  (when forge-c++-literal-integer
    (font-lock-remove-keywords mode forge-font-lock-c++-literal-integer))
  (when forge-c++-literal-null-pointer
    (font-lock-remove-keywords mode forge-font-lock-c++-literal-null-pointer))
  (when forge-c++-literal-string
    (font-lock-remove-keywords mode forge-font-lock-c++-literal-string))
  (when forge-c++-stl-cstdint
    (font-lock-remove-keywords mode forge-font-lock-c++-stl-cstdint)))

;;;###autoload
(define-minor-mode forge-font-lock-c++-mode
  "Provides font-locking as a Minor Mode for Modern C++"
  :init-value nil
  :lighter " mc++fl"
  :group 'forge-font-lock-c++
  (if forge-font-lock-c++-mode
      (forge-font-lock-c++-add-keywords)
    (forge-font-lock-c++-remove-keywords))
  ;; As of Emacs 24.4, `font-lock-fontify-buffer' is not legal to
  ;; call, instead `font-lock-flush' should be used.
  (if (fboundp 'font-lock-flush)
      (font-lock-flush)
    (when font-lock-mode
      (with-no-warnings
        (font-lock-fontify-buffer)))))

;;;###autoload
(define-global-minor-mode forge-font-lock-c++-mode forge-font-lock-c++-mode
  (lambda ()
    (when (apply 'derived-mode-p '(c++-mode))
      (forge-font-lock-c++-mode 1)))
  :group 'forge-font-lock-c++)

(provide 'forge-font-lock-cpp)

;; coding: utf-8

;;; forge-font-lock-cpp.el ends here
