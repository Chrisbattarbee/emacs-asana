;;; emacs-asana.el --- Interface with Asana via org mode and agenda

;; Author: Chris Battarbee <chris@chrisbattarbee.com>
;; Version: 0.1
;; Package-eqires: ((request "0.3.2"))
;; Keywords: multimedia, hypermedia
;; URL: https://github.com/Chrisbattarbee/emacs-asana

;;; Commentary:

;; This package provides an interface between emacs org mode and asana.com.
;; It allows you to import tasks from asana and export org mode tasks to asana.


;;;###autoload

;; Basic workings:
;; Pull all tasks from the target asana project
;; Gather all tasks in agenda
;; Convert them into an intermediate format
;; Apply a resolution strategy between tasks that exist in both systems
;; Update local tasks
;; Update remote asana tasks

;; Variables

(defvar em-as-project-gid nil
  "The asana project gid that emacs-asana will write to.")

(defvar em-as-asana-file-path nil
  "The path of the file that emacs-asana will write tasks that have been created in asana but do not exist in agenda.")

(defvar em-as-asana-bearer-token nil
  "The bearer token used to auth with asana.")

(defvar em-as-input-files org-agenda-files
  "The files that emacs-asana will look through when collecting todos to sync.")

;; Functions

(defun flatten (list-of-lists)
  "Takes a LIST-OF-LISTS and return the elements of each in one list."
  (apply #'append list-of-lists))

(defun all-top-level-todos ()
  "Return all todos from agenda which do not have a parent todo."
  (seq-filter '(lambda (x) x) (org-map-entries '(return-element-if-no-todo-parent) 't 'agenda)))

(defun path-to-tree (path)
  "Takes a PATH of a file and return the org-element-trees associated with it."
  (interactive)
  (find-file path)
  (org-ml-get-subtrees))

(defun agenda-files-to-trees ()
  "Return all subtrees of all agenda files."
  (flatten (mapcar 'path-to-tree em-as-input-files)))

(defun top-level-todos-for-node (node)
  "Recursively find the top level todo items for a NODE, that is to say any todos with no todo above them in the tree."
  (cond ((condition-case nil (org-ml-get-property :todo-keyword node) (error nil)) (list node))
        ((eq (length (org-ml-get-children node)) 0) '())
        (t (flatten (mapcar 'top-level-todos-for-node (org-ml-get-children node))))))

(defun top-level-todos-for-nodes (nodes)
  "Return all top level todos of a list of NODES."
  (flatten (seq-filter (lambda (x) x) (mapcar 'top-level-todos-for-node nodes))))

(defun next-level-todos-for-node (node)
  "Given a todo NODE, find the next level of sub todos."
  (top-level-todos-for-nodes (org-ml-get-children node)))

(defun map-element-to-asana-task (node)
  "TODO: Take an org element in NODE and return the json data payload to be sent to asana.")

(defun create-asana-task (node)
  "TODO: Take an org element in NODE and create an asana task from it.")

(defun update-asana-task (node)
  "TODO: Take an org element in NODE and update the corresponding asana entry.  NODE must have a ASANA-TASK-GID property.")

(defun update-or-add-to-asana (nodes)
  "TODO: For each todo node in NODES the function will check to see if the element has a task-gid property, if it does not, it will create the asana task and update the property, otherwise it will update the task in asana with all current properties."
    )


;; Playground


(defun print-elements-of-list (list)
  "Print each element of LIST on a line of its own."
  (while list
    (print (car list))
    (setq list (cdr list))))


(setq subtrees (nth 0(list (path-to-tree "~/notes/gtd/today.org"))))

(length subtrees)

(print-elements-of-list (top-level-todos-for-nodes subtrees))

(mapcar (lambda (x) (org-ml-get-property :title x)) (top-level-todos-for-nodes subtrees))
 
(org-ml-headline-get-node-property "CREATED" (nth 0 (next-level-todos-for-node (nth 0 (top-level-todos-for-nodes subtrees)))))

(request
 "http://httpbin.org/get"
 :params '(("test" . "test2") ("key2" . "value2"))
 :parser 'json-read
 :success (cl-function
           (lambda (&key data &allow-other-keys)
             (message "I sent: %S" (assoc-default 'args data)))))

(provide 'emacs-asana)
