;; Don't show the splash screen
(setq inhibit-startup-message t)
;; Turn off some unneeded UI elements
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
;; Display line numbers in every buffer
(global-display-line-numbers-mode 1)
;; Remembering recently edited files
(recentf-mode 1)
;; Save what you enter into minibuffer prompts
(setq history-length 25)
(savehist-mode 1)
;; Remember and restore the last cursor location of opened files
(save-place-mode 1)
;; Move customization variables to a separate file and load it
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)
;; Don't pop up UI dialogs when prompting
(setq use-dialog-box nil)
;; Disable audible bell and enable visible bell
(setq visible-bell t)
;; Set default theme
(load-theme 'modus-operandi t)
;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)
;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)
;; Customize org-mode
(defun dw/org-mode-setup ()
  (org-indent-mode 1)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1))
(use-package org
  :ensure t
  :hook (org-mode . dw/org-mode-setup)
  :config
  ;; Open file in same window
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file))
;; Set default fonts
(cond
 ((member "Iosevka Fixed" (font-family-list))
  (set-face-attribute 'default nil :font "Iosevka Fixed")
  (set-face-attribute 'default nil :height 140)))
;; Initialize package management system and add MELPA repository
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'magit)
  (package-install 'magit))
