(require 'package)
(push '("marmalade" . "http://marmalade-repo.org/packages/") package-archives)
(push '("melpa" . "http://melpa.milkbox.net/packages/") package-archives)
(push '("org" . "http://orgmode.org/elpa/") package-archives)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

(setq use-package-always-ensure t)

;; Packages
(use-package protobuf-mode :ensure t :init)
(use-package go-mode :ensure t :init)
(use-package flycheck :ensure t)
(use-package yaml-mode :ensure t)

(use-package base16-theme :ensure t :init (load-theme 'base16-grayscale-dark :no-confirm))

(use-package exec-path-from-shell
  :ensure t
  :init
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize))
  )
(use-package multiple-cursors
  :ensure t
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-w" . mc/mark-all-like-this))
  )
(use-package ido-vertical-mode
  :ensure t
  :init
  (ido-mode 1)
  (ido-vertical-mode 1)
  (setq ido-vertical-define-keys 'C-n-C-p-up-down-left-right)
  )

;; Golang
(setenv "GOPATH" "/Users/caires/go/work")
(defun my-go-mode-hook ()
  ; Use goimports instead of go-fmt
  (setq gofmt-command "goimports")
  ; Call Gofmt before saving
  (add-hook 'before-save-hook 'gofmt-before-save)
  ; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go generate && go build -v && go test -v && go vet"))
  ; Godef jump key binding
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "M-*") 'pop-tag-mark)
)
(add-hook 'go-mode-hook 'my-go-mode-hook)
;;(add-to-list 'load-path "~/go/work/src/github.com/dougm/goflymake")
;; (require 'go-flymake)

;; (add-to-list 'load-path "~/go/work/gocode/src/github.com/dougm/goflymake")
;; (require 'go-flycheck)

;;org-mode
(setq org-src-fontify-natively t)
(global-set-key (kbd "C-c o") 
                (lambda () (interactive) (find-file "~/organizer.org")))
(global-set-key (kbd "C-c c") 'org-capture)
(setq org-default-notes-file "~/organizer.org")

;; Remapping, buffers, etc...
;; change alt to esc
(setq mac-option-key-is-meta t)
(setq mac-right-option-modifier nil)
;; clock
(display-time)

;; binds
(defun append-as-kill ()
  "Performs copy-region-as-kill as an append."
  (interactive)
  (append-next-kill) 
  (copy-region-as-kill (mark) (point))
  )

(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(global-set-key "\C-x\k" 'kill-this-buffer)

;; autocompletion
(global-set-key (kbd "M-/") 'hippie-expand)
(setq hippie-expand-try-functions-list '(try-expand-dabbrev try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill try-complete-file-name-partially try-complete-file-name try-expand-all-abbrevs try-expand-list try-expand-line try-complete-lisp-symbol-partially try-complete-lisp-symbol))

(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)
(global-hl-line-mode 1)
(blink-cursor-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode 0)
(require 'ido)
(ido-mode t)
(setq scroll-step 3)
(setq org-completion-use-ido t)
(setq inhibit-splash-screen t)
(delete-selection-mode 1)
(global-set-key (kbd "C-x g") 'magit-status)
(setq tramp-default-method "ssh")

;; Font (Fira code) <3
(when (window-system)
  (set-default-font "Fira Code"))
(let ((alist '((33 . ".\\(?:\\(?:==\\|!!\\)\\|[!=]\\)")
               (35 . ".\\(?:###\\|##\\|_(\\|[#(?[_{]\\)")
               (36 . ".\\(?:>\\)")
               (37 . ".\\(?:\\(?:%%\\)\\|%\\)")
               (38 . ".\\(?:\\(?:&&\\)\\|&\\)")
               (42 . ".\\(?:\\(?:\\*\\*/\\)\\|\\(?:\\*[*/]\\)\\|[*/>]\\)")
               (43 . ".\\(?:\\(?:\\+\\+\\)\\|[+>]\\)")
               (45 . ".\\(?:\\(?:-[>-]\\|<<\\|>>\\)\\|[<>}~-]\\)")
               (46 . ".\\(?:\\(?:\\.[.<]\\)\\|[.=-]\\)")
               (47 . ".\\(?:\\(?:\\*\\*\\|//\\|==\\)\\|[*/=>]\\)")
               (48 . ".\\(?:x[a-zA-Z]\\)")
               (58 . ".\\(?:::\\|[:=]\\)")
               (59 . ".\\(?:;;\\|;\\)")
               (60 . ".\\(?:\\(?:!--\\)\\|\\(?:~~\\|->\\|\\$>\\|\\*>\\|\\+>\\|--\\|<[<=-]\\|=[<=>]\\||>\\)\\|[*$+~/<=>|-]\\)")
               (61 . ".\\(?:\\(?:/=\\|:=\\|<<\\|=[=>]\\|>>\\)\\|[<=>~]\\)")
               (62 . ".\\(?:\\(?:=>\\|>[=>-]\\)\\|[=>-]\\)")
               (63 . ".\\(?:\\(\\?\\?\\)\\|[:=?]\\)")
               (91 . ".\\(?:]\\)")
               (92 . ".\\(?:\\(?:\\\\\\\\\\)\\|\\\\\\)")
               (94 . ".\\(?:=\\)")
               (119 . ".\\(?:ww\\)")
               (123 . ".\\(?:-\\)")
               (124 . ".\\(?:\\(?:|[=|]\\)\\|[=>|]\\)")
               (126 . ".\\(?:~>\\|~~\\|[>=@~-]\\)")
               )
             ))
  (dolist (char-regexp alist)
    (set-char-table-range composition-function-table (car char-regexp)
                          `([,(cdr char-regexp) 0 font-shape-gstring]))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-term-color-vector
   [unspecified "#101010" "#7c7c7c" "#8e8e8e" "#a0a0a0" "#686868" "#747474" "#686868" "#b9b9b9"])
 '(custom-safe-themes
   (quote
    ("12670281275ea7c1b42d0a548a584e23b9c4e1d2dabb747fd5e2d692bcd0d39b" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'upcase-region 'disabled nil)

(require 'org)

(defvar org-s5-theme "default")

(defvar org-s5-ui-dir "ui")

(defvar org-s5-title-string-fmt "<h1>%author - %title</h1>"
  "Format template to specify title string.  Completed using `org-fill-template'.
Optional keys include %author, %title and %date.")

(defvar org-s5-title-page-fmt (mapconcat #'identity
                                         '("<div class=\"slide\">"
                                           "<h1>%title</h1>"
                                           "<h1>%author</h1>"
                                           "<h1>%date</h1>"
                                           "</div>")
                                         "\n")
  "Format template to specify title page.  Completed using `org-fill-template'.
Optional keys include %author, %title and %date.")

(defun org-export-format-drawer-s5 (name content)
  (if (string-equal name "NOTES")
      (concat "\n#+BEGIN_HTML\n<div class=\"notes\">\n#+END_HTML\n" content "\n#+BEGIN_HTML\n</div\n#+END_HTML\n")
    (org-export-format-drawer name content)))

(defun org-export-as-s5
  (arg &optional ext-plist to-buffer body-only pub-dir)
  "Wrap `org-export-as-html' in setting for S5 export."
  (interactive "P")
  (add-to-list 'org-drawers "NOTES")
  (flet ((join (lst) (mapconcat #'identity lst "\n"))
         (sheet (href media id)
                (org-fill-template
                 (concat "<link rel=\"stylesheet\" href=\""
                         org-s5-ui-dir
                         "/%href\""
                         " type=\"text/css\" media=\"%media\" id=\"%id\" />")
                 `(("href" . ,href)
                   ("media" . ,media)
                   ("id" . ,id)))))
    (let ((org-export-html-style-extra
           (join `("<!-- configuration parameters -->"
                   "<meta name=\"defaultView\" content=\"slideshow\" />"
                   "<meta name=\"controlVis\" content=\"hidden\" />"
                   "<!-- style sheet links -->"
                   ,(sheet (concat org-s5-theme "/slides.css")
                           "projection" "slideProj")
                   ,(sheet "default/outline.css" "screen" "outlineStyle")
                   ,(sheet "default/print.css" "print" "slidePrint")
                   ,(sheet "default/opera.css" "projection" "operaFix")
                   "<!-- S5 JS -->"
                   ,(concat "<script src=\"" org-s5-ui-dir
                            "/default/slides.js\" "
                            "type=\"text/javascript\"></script>"))))
          (org-export-html-toplevel-hlevel 1)
          (org-export-html-postamble nil)
          (org-export-html-auto-postamble nil)
          (org-export-with-drawers (list "NOTES"))
          (org-export-format-drawer-function 'org-export-format-drawer-s5)
          (org-export-preprocess-hook
           (list
            (lambda ()
              (let ((class "slide"))
                (org-map-entries
                 (lambda ()
                   (save-excursion
                     (org-back-to-heading t)
                     (when (= (car (org-heading-components)) 1)
                       (put-text-property (point-at-bol) (point-at-eol)
                                          'html-container-class class)))))))))
          (org-export-html-final-hook
           (list
            (lambda ()
              (save-excursion
                (replace-regexp
                 (regexp-quote "<div id=\"content\">")
                 (let ((info `(("author" . ,author)
                               ("title"  . ,title)
                               ("date"   . ,(substring date 0 10)))))
                   (join `("<div class=\"layout\">"
                           "<div id=\"controls\"><!-- no edit --></div>"
                           "<div id=\"currentSlide\"><!-- no edit --></div>"
                           "<div id=\"header\"></div>"
                           "<div id=\"footer\">"
                           ,(org-fill-template org-s5-title-string-fmt info)
                           "</div>"
                           "</div>"
                           ""
                           "<div class=\"presentation\">"
                           ,(org-fill-template org-s5-title-page-fmt info)))))))
            (lambda ()
              (save-excursion
                (replace-regexp
                 (regexp-quote "<div id=\"table-of-contents\">")
                 "<div id=\"table-of-contents\" class=\"slide\">"))))))
      (org-export-as-html arg ext-plist to-buffer body-only pub-dir))))

(provide 'org-export-as-s5)
(put 'downcase-region 'disabled nil)
