;;; major-mode-log.el --- loggin major mode          -*- lexical-binding: t; -*-

;; Copyright (C) 2015  南優也

;; Author: 南優也 <yuyaminami@minamiyuunari-no-MacBook-Pro.local>
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(defcustom mml/log-buffer-name "*mml/log-buffer*"
  "Buffer name used to log `major-mode`.")

(defcustom mml/exclude-major-mode '(minibuffer-inactive-mode)
  "Exclude from logging to buffer.")

(defcustom mml/log-file-directory (concat user-emacs-directory "major-mode-log/")
  "Directory to save log buffer.")

(defun mml/logging-to-buffer ()
  (let ((buf (get-buffer-create mml/log-buffer-name))
        (time (format-time-string "%F %T"))
        (major-mode-str (symbol-name major-mode))
        (file-name (buffer-file-name)))
    (with-current-buffer buf
      (unless (memq major-mode mml/exclude-major-mode)
        (goto-char (point-max))
        (insert (format "%s,%s,%s\n"
                        time
                        major-mode-str
                        file-name))))))

(defun mml/save-log-buffer-to-file ()
  (let ((buf (get-buffer mml/log-buffer-name))
        (file-name (format-time-string "%F")))
    (if buf
        (with-current-buffer buf
          (write-region (point-min) (point-max)
                        (concat mml/log-file-directory file-name)
                        t
                        'nomsg)
          (delete-region (point-min) (point-max))))))

(mml/save-log-buffer-to-file)

;;;###autoload
(define-minor-mode major-mode-log-mode
  "Major-mode-log mode"
  :group 'major-mode-log
  :init-value nil
  :global nil
  (if major-mode-log-mode
      (progn
        (add-hook 'find-file-hook 'mml/logging-to-buffer)
        (add-hook 'kill-emacs-hook 'mml/save-log-buffer-to-file))
    (remove-hook 'find-file-hook 'mml/logging-to-buffer)
    (remove-hook 'kill-emacs-hook 'mml/save-log-buffer-to-file)))

(defun major-mode-log--turn-on ()
  (major-mode-log-mode +1))

;;;###autoload
(define-global-minor-mode global-major-mode-log-mode major-mode-log-mode
  major-mode-log--turn-on
  :group 'major-mode-log)

(provide 'major-mode-log)
;;; major-mode-log.el ends here
