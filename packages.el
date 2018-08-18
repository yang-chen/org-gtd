;;; packages.el --- gtd Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2015 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq gtd-packages
      '(org
        org-agenda))

;; List of packages to exclude.
(setq gtd-excluded-packages '())

(defun gtd/post-init-org()
  ;; Some general settings
  (setq org-directory '("~/org"))
  (setq org-agenda-files '("~/org"))
  (setq org-default-notes-file "~/org/refile.org")
  (defvar org-default-diary-file "~/org/diary.org")

  ;; Display properties
  (setq org-cycle-separator-lines 0)
  (setq org-tags-column 80)
  (setq org-agenda-tags-column org-tags-column)
  (setq org-agenda-sticky t)

  ;; Set default column view headings: Task Effort Clock_Summary
  (setq org-columns-default-format
        "%50ITEM(Task) %10TODO %3PRIORITY %TAGS %10Effort(Effort){:} %10CLOCKSUM")

  ;; == Tags ==
  ;; Allow setting single tags without the menu
  (setq org-fast-tag-selection-single-key 'expert)
  ;; Include the todo keywords
  (setq org-fast-tag-selection-include-todo t)
  (setq org-use-fast-todo-selection t)

  (setq org-tag-alist (quote ((:startgroup)
                              ("@errand" . ?e)
                              ("@office" . ?o)
                              ("@home" . ?h)
                              (:endgroup)
                              ("WAITING" . ?W)
                              ("HOLD" . ?H)
                              ("PERSONAL" . ?P)
                              ("WORK" . ?W)
                              ("NOTE" . ?N)
                              ("CANCELLED" . ?C))))

  ;; =TODO= state keywords and colour settings:
  (setq org-todo-keywords
        (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
                (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))

  ;; TODO Other todo keywords doesn't have appropriate faces yet. They should
  ;; have faces similar to spacemacs defaults.
  (setq org-todo-keyword-faces
        (quote (("TODO" :foreground "red" :weight bold)
                ("NEXT" :foreground "blue" :weight bold)
                ("DONE" :foreground "forest green" :weight bold)
                ("WAITING" :foreground "orange" :weight bold)
                ("HOLD" :foreground "magenta" :weight bold)
                ("CANCELLED" :foreground "forest green" :weight bold)
                ("MEETING" :foreground "forest green" :weight bold)
                ("PHONE" :foreground "forest green" :weight bold))))

  (setq org-todo-state-tags-triggers
        (quote (("CANCELLED" ("CANCELLED" . t))
                ("WAITING" ("WAITING" . t))
                ("HOLD" ("WAITING") ("HOLD" . t))
                (done ("WAITING") ("HOLD"))
                ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
                ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

  ;; Capture templates for: TODO tasks, Notes, appointments, phone calls,
  ;; meetings, and org-protocol
  (setq org-capture-templates
        (quote (("t" "todo" entry (file "~/org/refile.org")
                 "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
                ("r" "respond" entry (file "~/org/refile.org")
                 "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
                ("n" "note" entry (file "~/org/refile.org")
                 "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
                ("j" "Journal" entry (file+datetree "~/org/diary.org")
                 "* %?\n%U\n" :clock-in t :clock-resume t)
                ("w" "org-protocol" entry (file "~/org/refile.org")
                 "* TODO Review %c\n%U\n" :immediate-finish t)
                ("m" "Meeting" entry (file "~/org/refile.org")
                 "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
                ("p" "Phone call" entry (file "~/org/refile.org")
                 "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
                ("h" "Habit" entry (file "~/org/refile.org")
                 "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n"))))

  ;; == Refile ==
  ;; Targets include this file and any file contributing to the agenda - up to 9 levels deep
  (setq org-refile-targets (quote ((nil :maxlevel . 9)
                                   (org-agenda-files :maxlevel . 9))))

  ;;  Be sure to use the full path for refile setup
  (setq org-refile-use-outline-path t)
  (setq org-outline-path-complete-in-steps nil)

  ;; Allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  ;; == Archive ==
  (setq org-archive-location "archive/%s_archive::")
  (defvar org-archive-file-header-format "#+FILETAGS: ARCHIVE\nArchived entries from file %s\n")

  ;; == Habits ==
  (require 'org-habit)

  (setq org-modules '(org-habit))
  (setq org-habit-show-habits-only-for-today t)

  ;; == Clocking Functions ==
  (require 'org-clock)

  ;; If not a project, clocking-in changes TODO to NEXT
  (setq org-clock-in-switch-to-state 'gtd/clock-in-to-next)
  (defun gtd/clock-in-to-next (kw)
    "Switch a task from TODO to NEXT when clocking in.
Skips capture tasks, projects, and subprojects.
Switch projects and subprojects from NEXT back to TODO"
    (when (not (and (boundp 'org-capture-mode) org-capture-mode))
      (cond
       ((and (member (org-get-todo-state) (list "TODO"))
             (not (gtd/is-project-p)))
        "NEXT")
       ((and (member (org-get-todo-state) (list "NEXT"))
             (gtd/is-project-p))
        "TODO"))))
)

(defun gtd/post-init-org-agenda()
  ;; == Agenda ==
  ;; Dim blocked tasks (and other settings)
  (setq org-enforce-todo-dependencies t)
  (setq org-agenda-inhibit-startup nil)
  (setq org-agenda-dim-blocked-tasks nil)

  ;; Compact the block agenda view (disabled)
  (setq org-agenda-compact-blocks nil)

  ;; Set the times to display in the time grid
  (setq org-agenda-time-grid
        '((daily today nil)
          (900 1200 1500 1800)
          "......" "----------------"))

  ;; Variables for ignoring tasks with deadlines
  (setq org-agenda-tags-todo-honor-ignore-options nil)
  (setq org-deadline-warning-days 7)

  ;; Agenda log mode items to display (closed and state changes by default)
  (setq org-agenda-log-mode-items (quote (closed clock state)))

  ;; Some helper functions for selection within agenda views
  (defun gtd/is-project-p ()
    "Any task with a todo keyword subtask."
    (save-restriction
      (widen)
      (let ((has-subtask)
            (subtree-end (save-excursion (org-end-of-subtree t)))
            (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-todo-keywords-1)
              (setq has-subtask t))))
        (and is-a-task has-subtask))))

  (defun gtd/is-task-p ()
    "Any task with a todo keyword and no subtask"
    (save-restriction
      (widen)
      (let ((has-subtask)
            (subtree-end (save-excursion (org-end-of-subtree t)))
            (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-todo-keywords-1)
              (setq has-subtask t))))
        (and is-a-task (not has-subtask)))))

  (defun gtd/select-with-tag-function (select-fun-p)
    (save-restriction
      (widen)
      (let ((next-headline
             (save-excursion (or (outline-next-heading)
                                 (point-max)))))
        (if (funcall select-fun-p) nil next-headline))))

  (defun gtd/select-projects ()
    "Selects tasks which are project headers"
    (gtd/select-with-tag-function
     #'(lambda () (and
                   (gtd/is-project-p)
                   (not (gtd/org-agenda-project-is-stuck))))))

  (defun gtd/select-tasks ()
    "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
        (cond
         ((gtd/is-task-p)
          nil)
         (t
          next-headline)))))

  (defun gtd/select-stuck-projects ()
    "Selects stuck projects"
    (gtd/select-with-tag-function #'gtd/org-agenda-project-is-stuck))

  (defun gtd/org-agenda-project-warning ()
    "Is a project stuck or waiting. If the project is not stuck,
show nothing. However, if it is stuck and waiting on something,
show this warning instead."
    (if (gtd/org-agenda-project-is-stuck)
        (if (gtd/org-agenda-project-is-waiting) " !W" " !S") ""))

  (defun gtd/org-agenda-project-is-stuck ()
    "Is a project stuck"
    (if (gtd/is-project-p) ; first, check that it's a project
        (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
               (has-next))
          (save-excursion
            (forward-line 1)
            (while (and (not has-next)
                        (< (point) subtree-end)
                        (re-search-forward "^\\*+ NEXT " subtree-end t))
              (unless (member "WAITING" (org-get-tags-at))
                (setq has-next t))))
          (if has-next nil t)) ; signify that this project is stuck
      nil)) ; if it's not a project, return an empty string

  (defun gtd/org-agenda-project-is-waiting ()
    "Is a project stuck"
    (if (gtd/is-project-p) ; first, check that it's a project
        (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
          (save-excursion
            (re-search-forward "^\\*+ WAITING" subtree-end t)))
      nil)) ; if it's not a project, return an empty string

  ;; Some helper functions for agenda views
  (defun gtd/org-agenda-prefix-string ()
    "Format"
    (let ((path (org-format-outline-path (org-get-outline-path))) ; "breadcrumb" path
          (stuck (gtd/org-agenda-project-warning))) ; warning for stuck projects
      (if (> (length path) 0)
          (concat stuck ; add stuck warning
                  " [" path "]") ; add "breadcrumb"
        stuck)))

  (defun gtd/org-agenda-add-location-string ()
    "Gets the value of the LOCATION property"
    (let ((loc (org-entry-get (point) "LOCATION")))
      (if (> (length loc) 0)
          (concat "{" loc "} ")
        "")))

  (defun gtd/select-archivable-tasks ()
    "Skip trees that are not available for archiving"
    (save-restriction
      (widen)
      ;; Consider only tasks with done todo headings as archivable candidates
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
            (subtree-end (save-excursion (org-end-of-subtree t))))
        (if (member (org-get-todo-state) org-todo-keywords-1)
            (if (member (org-get-todo-state) org-done-keywords)
                (let* ((daynr (string-to-int (format-time-string "%d" (current-time))))
                       (a-month-ago (* 60 60 24 (+ daynr 1)))
                       (last-month (format-time-string "%Y-%m-" (time-subtract (current-time) (seconds-to-time a-month-ago))))
                       (this-month (format-time-string "%Y-%m-" (current-time)))
                       (subtree-is-current (save-excursion
                                             (forward-line 1)
                                             (and (< (point) subtree-end)
                                                  (re-search-forward (concat last-month "\\|" this-month) subtree-end t)))))
                  (if subtree-is-current
                      subtree-end ; Has a date in this month or last month, skip it
                    nil))  ; available to archive
              (or subtree-end (point-max)))
          next-headline))))

  ;; Custom agenda command definitions
  (setq org-agenda-custom-commands
        (quote (("n" "Notes" tags "NOTE"
                 ((org-agenda-overriding-header "Notes")
                  (org-tags-match-list-sublevels t)))
                ("h" "Habits" tags-todo "STYLE=\"habit\""
                 ((org-agenda-overriding-header "Habits")
                  (org-agenda-sorting-strategy
                   '(todo-state-down effort-up category-keep))))
                (" " "Agenda"
                 ((agenda "" ((org-agenda-start-day "today")
                              (org-agenda-span 7)
                              (org-agenda-start-on-weekday nil)
                              (org-agenda-show-all-dates t)
                              (org-agenda-use-time-grid t)
                              (org-agenda-show-log t)))
                  (tags-todo "/!NEXT"
                             ((org-agenda-overriding-header "Next Tasks")))
                  (tags "REFILE"
                        ((org-agenda-overriding-header "Tasks to Refile")
                         (org-tags-match-list-sublevels nil)))
                  (tags-todo "-HOLD-CANCELLED/!"
                             ((org-agenda-overriding-header "Active Projects")
                              (org-agenda-skip-function 'gtd/select-projects)
                              (org-tags-match-list-sublevels 'indented)
                              (org-agenda-sorting-strategy '(category-keep))))
                  (tags-todo "-CANCELLED-WAITING/-NEXT"
                             ((org-agenda-overriding-header "Tasks")
                              (org-agenda-skip-function 'gtd/select-tasks)
                              (org-agenda-sorting-strategy
                               '(todo-state-down category-keep))))
                  (tags-todo "-CANCELLED-WAITING/!"
                             ((org-agenda-overriding-header "Projects")
                              (org-agenda-skip-function 'gtd/select-stuck-projects)
                              (org-tags-match-list-sublevels 'indented)
                              (org-agenda-sorting-strategy '(category-keep))))
                  (tags-todo "-CANCELLED+WAITING|HOLD/!"
                             ((org-agenda-overriding-header "Waiting and Postponed Tasks")
                              (org-agenda-skip-function 'gtd/select-tasks)
                              (org-tags-match-list-sublevels nil)))
                  (tags "-REFILE/"
                        ((org-agenda-overriding-header "Tasks to Archive")
                         (org-agenda-skip-function 'gtd/select-archivable-tasks)
                         (org-tags-match-list-sublevels nil))))
                 nil)
                ("w" "Week Review"
                 ((agenda "" ((org-agenda-span 7)
                              (org-agenda-start-on-weekday 1)
                              (org-agenda-entry-types '(:timestamp))
                              (org-agenda-show-all-dates t)
                              (org-agenda-use-time-grid nil)
                              (org-agenda-show-log t))))))))
)
