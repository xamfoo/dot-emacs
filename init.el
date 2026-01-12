;; -*- lexical-binding: t; -*-
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
;; Use fontset for emoji
(setq use-default-font-for-symbols nil)
;; Touchscreen keyboard always on
(setq touch-screen-display-keyboard t)
;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)
;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)
;; Disable text-conversion by default
(setq overriding-text-conversion-style nil)
;; Initialize package management system and add MELPA repository
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(use-package ef-themes
  :ensure t
  :init
  (ef-themes-take-over-modus-themes-mode 1)
  :config
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t)
  (modus-themes-load-theme 'ef-elea-dark)
  (cond
   ((member "Iosevka Fixed" (font-family-list))
    (set-face-attribute 'default nil :family "Iosevka Fixed" :height 140 :weight 'medium)
    (set-face-attribute 'fixed-pitch nil :family "Iosevka Fixed" :weight 'medium)))
  (cond
   ((member "Iosevka Aile" (font-family-list))
    (set-face-attribute 'variable-pitch nil :family "Iosevka Aile" :height 140)))
  ;; 🥰💀✌️🌴🐢🐐🍄⚽🍻👑📸😬👀🚨🏡🕊️🏆😻🌟🧿🍀🎨🍜
  (set-fontset-font t 'emoji (font-spec :family "Noto Color Emoji") nil 'append)
  (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji") nil 'append)
  (set-fontset-font t 'emoji (font-spec :family "Noto Emoji") nil 'append)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch :height 100)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch :height 100))
(use-package magit
  :defer t
  :ensure t)
(when (stringp termux-emacs-vterm-dir)
  (use-package vterm
    :ensure t
    :load-path termux-emacs-vterm-dir))
(use-package markdown-mode
  :ensure t
  :init (setq markdown-command "pandoc"))
;; Customize org-mode
(defun dw/org-mode-setup ()
  (org-indent-mode 1)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (org-superstar-mode 1)
  (org-super-agenda-mode 1))
(defvar my/org-agenda-git-ls-files
  '("git" "ls-files" "--cached" "--modified" "--others" "--exclude-standard" "--full-name")
  "Return the git command to list files.")
(defun my/org-agenda-git-ls-files-async (callback &optional git-dir git-pattern)
  "Asynchronously run `git ls-files` and call CALLBACK with the result.

CALLBACK is called with a list of absolute file names.
GIT-DIR, if non-nil, is used as `default-directory`.
GIT-PATTERN, if non-nil, is passed after `--` to git."
  (let* ((default-directory (or git-dir default-directory))
         (buffer (generate-new-buffer "*git ls-files*"))
         (args (append my/org-agenda-git-ls-files
                       (when git-pattern (list "--" git-pattern))))
         (process (apply #'start-process
                         "org-agenda-git-files"
                         buffer
                         args)))
    (set-process-sentinel
     process
     (lambda (proc event)
       (when (eq (process-status proc) 'exit)
         (unwind-protect
             (with-current-buffer (process-buffer proc)
               (if (= (process-exit-status proc) 0)
                   ;; Success: call callback with files
                   (let ((files
                          (mapcar #'expand-file-name
                                  (split-string (buffer-string) "\n" t))))
                     (funcall callback files))
                 ;; Failure: print error message
                 (message "Error running git ls-files: %s"
                          (string-trim (buffer-string))))))
         (kill-buffer (process-buffer proc)))))))
(defun my/directories-of-files (files)
  "List of unique directories where files exist"
  (delete-dups (mapcar #'file-name-directory files)))
(use-package org
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link))
  :ensure t
  :config
  (let* ((note-dir "~/code/note")
	 (note-git-files-pattern "*.org")
	 (note-inbox-file (concat note-dir "/gtd/10_inbox/inbox.org")))
    (my/org-agenda-git-ls-files-async
     (lambda (files)
       (setq org-agenda-files (my/directories-of-files files))
       (setq org-refile-targets
	     '((nil :maxlevel . 9)
	       (org-agenda-files :maxlevel . 9))))
     note-dir note-git-files-pattern)
    (setq org-default-notes-file note-inbox-file)
    ;; Open file in same window
    (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file))
  :custom
  (org-habit-graph-column 50)
  (org-habit-show-all-today t)
  (org-use-property-inheritance '("Context" "Section"))
  :hook (org-mode . dw/org-mode-setup))
(use-package org-faces
  :ensure nil
  :custom-face
  (org-table ((nil (:inherit fixed-pitch))))
  (org-block ((nil (:inherit fixed-pitch :foreground nil))))
  (org-code ((nil (:inherit (shadow fixed-pitch)))))
  (org-indent ((nil (:inherit (org-hide fixed-pitch)))))
  (org-special-keyword ((nil (:inherit (font-lock-comment-face fixed-pitch)))))
  (org-list-dt ((nil (:inherit fixed-pitch)))))
(use-package org-super-agenda
  :ensure t
  :config
  (setq
   org-agenda-custom-commands
   '(("A" "Agenda Overview"
      ((agenda
        ""
        ((org-agenda-span 'day)
         (org-super-agenda-groups
          '((:log t)  ; Automatically named "Log"
            (:name "Schedule"
                   :time-grid t)
            (:name "Today"
                   :scheduled today)
            (:habit t)
            (:name "Due today"
                   :deadline today)
            (:name "Overdue"
                   :deadline past)
            (:name "Due soon"
                   :deadline future)
            (:name "Scheduled earlier"
                   :scheduled past)))))))
     ("c" "Contexts Overview"
      ((todo
        ""
        ((org-super-agenda-groups
          '((:name "computer" :take (3 (:and (:property ("Context" "computer") :children nil :scheduled nil))))
	    (:name "errand" :take (3 (:and (:property ("Context" "errand") :children nil :scheduled nil))))
	    (:name "home" :take (3 (:and (:property ("Context" "home") :children nil :scheduled nil))))
	    (:name "phone" :take (3 (:and (:property ("Context" "phone") :children nil :scheduled nil))))
	    (:name "shopping" :take (3 (:and (:property ("Context" "shopping") :children nil :scheduled nil))))
	    (:name "think" :take (3 (:and (:property ("Context" "think") :children nil :scheduled nil))))
	    (:name "wait" :take (3 (:and (:property ("Context" "wait") :children nil :scheduled nil))))
	    (:discard (:anything t)))))))))))
(use-package org-superstar
  :ensure t)

