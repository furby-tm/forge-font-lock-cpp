;;; forge-font-lock-cpp-test-setup.el --- Setup and execute all tests

;;; Commentary:

;; This package sets up a suitable enviroment for testing
;; forge-font-lock-cpp, and executes the tests.
;;
;; Usage:
;;
;;   emacs -q -l forge-font-lock-cpp-test-setup.el
;;
;; Note that this package assumes that some packages are located in
;; specific locations.

;;; Code:

(prefer-coding-system 'utf-8)

(defvar forge-font-lock-cpp-test-setup-directory
  (if load-file-name
      (file-name-directory load-file-name)
    default-directory))

(dolist (dir '("." "./faceup"))
  (add-to-list 'load-path
               (concat forge-font-lock-cpp-test-setup-directory dir)))

(require 'forge-font-lock-cpp)
(add-hook 'text-mode-hook #'forge-font-lock-c++-mode)

(require 'forge-font-lock-cpp-test)

(ert t)

;;; forge-font-lock-cpp-test-setup.el ends here
