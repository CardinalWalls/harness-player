# Team Tasks — S002 Browser audit surface

This story is small enough for solo execution. If delegated, split only into disjoint phases:

1. Tester lane owns `scripts/verify_browser_audit_surface.py` and `.omx/evidence/S002-tester-*`.
2. Coder lane owns `web/index.html` and `.omx/evidence/S002-coder-*`.
3. Verifier lane owns final command evidence and forbidden-path scan.
