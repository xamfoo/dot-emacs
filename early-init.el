;; -*- lexical-binding: t; -*-
(defvar termux-emacs-vterm-dir nil
  "Default location of emacs vterm module")
(when (string-equal system-type "android")
  (let* ((termux-prefix "/data/data/com.termux")
         (termux-path (concat termux-prefix "/files/usr/bin"))
	 (termux-lib (concat termux-prefix "/files/usr/lib"))
         (termux-home (concat termux-prefix "/files/home"))
         (termux-shell (concat termux-path "/bash"))
         (termux-local-bin (concat termux-home "/.local/bin"))
         (path-dirs (list
		     termux-local-bin
                     termux-path)))
    (setenv
     "LD_PRELOAD"
     (concat termux-lib "/libtermux-exec-ld-preload.so"))
    (setenv
     "PATH"
     (mapconcat 'identity path-dirs ":"))
    (setq exec-path (append path-dirs exec-path))
    (setenv "SHELL" termux-shell)
    (setq shell-file-name termux-shell)
    (setenv "HOME" termux-home)
    (setq termux-emacs-vterm-dir
	  (concat termux-home "/.local/opt/emacs-libvterm"))))
(let* ((prev-paths (split-string (getenv "PATH") ":"))
       (home (getenv "HOME"))
       (add-paths (list
		   (concat home "/.nix-profile/bin")))
       (next-paths (append
		    (seq-difference add-paths prev-paths)
		    prev-paths))
       (next-exec-path (append
			(seq-difference add-paths exec-path)
			exec-path)))
  (setenv
   "PATH"
   (mapconcat 'identity next-paths ":"))
  (setq exec-path next-exec-path))
