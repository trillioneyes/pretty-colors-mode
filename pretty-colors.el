(eval-when-compile (require 'rainbow-delimiters))

(defvar rainbow-delimiters-faces-list
  '("rainbow-delimiters-depth-1-face"
    "rainbow-delimiters-depth-2-face"
    "rainbow-delimiters-depth-3-face"
    "rainbow-delimiters-depth-4-face"
    "rainbow-delimiters-depth-5-face"
    "rainbow-delimiters-depth-6-face"
    "rainbow-delimiters-depth-7-face"
    "rainbow-delimiters-depth-8-face"
    "rainbow-delimiters-depth-9-face"))
(defvar pretty-colors-open-delims '(?\( ?\[ ?\{))
(defvar pretty-colors-close-delims '(?\) ?\] ?\}))

(defun depth-from-base (loc base base-depth)
  (+ (car (parse-partial-sexp base loc)) base-depth))


(defun pretty-colors-colorize-region (start end)
  (interactive "r")
  (save-excursion
    (with-silent-modifications
      (pretty-colors-uncolorize-region start end)
      (font-lock-fontify-region start end)
      (goto-char start)
      (let ((start-depth (rainbow-delimiters-depth (point))))
       (while (< (point) end)
	 (let ((depth (depth-from-base (point) start start-depth)))
	   (when (and (memq (char-after (point)) pretty-colors-open-delims)
		      (not (rainbow-delimiters-char-ineligible-p (point))))
	     (setq depth (1+ depth)))
	   (unless (and (not (get-text-property (point) 'pretty-color))
			(or (and (get-text-property (point) 'font-lock-face))
			    (get-text-property (point) 'face)))
	     (add-text-properties
	      (point) (1+ (point))
	      `(font-lock-face ,(rainbow-delimiters-depth-face
				 depth)
			       pretty-color t))))
	 (setf (point) (1+ (point))))))))

(defun pretty-colors-uncolorize-region (start end)
  (save-excursion
    (with-silent-modifications
      (remove-text-properties start end
			      '(font-lock-face rainbow
					       pretty-color t)))))

(define-minor-mode pretty-colors-mode
  "Highlight parenthesis-like delimiters and their contents according to their depth."
  nil "" nil
  (if (not pretty-colors-mode)
      (progn
	(jit-lock-unregister 'pretty-colors-colorize-region)
	(pretty-colors-uncolorize-region (point-min) (point-max)))
    (rainbow-delimiters-mode-disable) ; ironically, rainbow-delimiters gets
                                      ; in the way
    (jit-lock-register 'pretty-colors-colorize-region t)
    ;(pretty-colors-colorize-region (point-min) (point-max))
    ))

(provide 'pretty-colors)
