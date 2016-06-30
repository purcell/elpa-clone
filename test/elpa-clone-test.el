(require 'f)
(require 'web-server)

(ert-deftest test-0001-local-clone ()
  (let* ((fixture-path (f-join fixture-root "0001-local-clone"))
         (source (f-join fixture-path "source"))
         (target (f-join fixture-path "target")))
    (elpa-clone source target)
    (should (f-file? (f-join target "archive-contents")))
    (should (f-file? (f-join target "a-1.el")))
    (should (f-file? (f-join target "b-2.tar")))))

(ert-deftest test-0002-local-clone-broken ()
  (let* ((fixture-path (f-join fixture-root "0002-local-clone-broken"))
         (source (f-join fixture-path "source"))
         (target (f-join fixture-path "target")))
    (should-error (elpa-clone source target)
                  :type 'end-of-file)
    (should-not (f-file? (f-join target "archive-contents")))
    (should-not (f-file? (f-join target "a-1.el")))
    (should-not (f-file? (f-join target "b-2.tar")))))

(ert-deftest test-0003-http-clone ()
  (let* ((fixture-path (f-join fixture-root "0003-http-clone"))
         (source (f-join fixture-path "source"))
         (target (f-join fixture-path "target"))
         (server (ws-start (make-static-handler source) 10003)))
    (unwind-protect
        (progn
          (elpa-clone source target)
          (should (f-file? (f-join target "archive-contents")))
          (should (f-file? (f-join target "a-1.el")))
          (should (f-file? (f-join target "b-2.tar"))))
      (ws-stop server))))

(ert-deftest test-0004-signature ()
  (let* ((fixture-path (f-join fixture-root "0004-signature"))
         (source (f-join fixture-path "source"))
         (target (f-join fixture-path "target")))
    (elpa-clone source target)
    (should (f-file? (f-join target "archive-contents")))
    (should (f-file? (f-join target "archive-contents.sig")))
    (should (f-file? (f-join target "a-1.el")))
    (should (f-file? (f-join target "a-1.el.sig")))
    (should (f-file? (f-join target "b-2.tar")))
    (should (f-file? (f-join target "b-2.tar.sig")))))

(ert-deftest test-0005-signature-lost ()
  (let* ((fixture-path (f-join fixture-root "0005-signature-lost"))
         (source (f-join fixture-path "source"))
         (target (f-join fixture-path "target")))
    (should-error (elpa-clone source target)
                  :type 'file-error)
    (should (f-file? (f-join target "archive-contents")))
    (should (f-file? (f-join target "archive-contents.sig")))
    (should-not (f-file? (f-join target "a-1.el")))
    (should-not (f-file? (f-join target "a-1.el.sig")))))

(ert-deftest test-0006-split-filename ()
  (should (equal (elpa-clone--split-filename "foo-bar-1.0-git.el")
                 (list "foo-bar" "1.0-git")))
  (should (equal (elpa-clone--split-filename "foo-bar-1.0-.el")
                 (list "foo-bar" "1.0-")))
  (should (equal (elpa-clone--split-filename "foo-bar.el")
                 (list "foo-bar")))
  (should (equal (elpa-clone--split-filename "baz/foo-bar-1.0.el")
                 (list "foo-bar" "1.0"))))

(ert-deftest test-0007-readme ()
  (let* ((fixture-path (f-join fixture-root "0007-readme"))
         (source (f-join fixture-path "source"))
         (target (f-join fixture-path "target")))
    (elpa-clone source target)
    (should (f-file? (f-join target "archive-contents")))
    (should (f-file? (f-join target "a-1.el")))
    (should (f-file? (f-join target "a-readme.txt")))
    (should (f-file? (f-join target "b-2.tar")))
    (should (f-file? (f-join target "b-readme.txt")))))

(ert-deftest test-0008-signature-never ()
  (let* ((fixture-path (f-join fixture-root "0008-signature-never"))
         (source (f-join fixture-path "source"))
         (target (f-join fixture-path "target")))
    (elpa-clone source target 'never)
    (should (f-file? (f-join target "archive-contents")))
    (should-not (f-file? (f-join target "archive-contents.sig")))
    (should (f-file? (f-join target "a-1.el")))
    (should-not (f-file? (f-join target "a-1.el.sig")))
    (should (f-file? (f-join target "b-2.tar")))
    (should-not (f-file? (f-join target "b-2.tar.sig")))))
