# 8. Automated Testing with Patrol

Students are required to implement automated end-to-end (E2E) tests using the **Patrol** testing framework.

The objective is to verify critical application workflows and improve software quality through automated testing.

## Required Test Scenarios

### Test Case 1 – Google Sign-In

- Launch the application.
- Perform Google Sign-In.
- Verify successful navigation to the Home screen.

---

### Test Case 2 – Topic Search

- Enter a research topic.
- Execute search.
- Verify publication results are displayed.

---

### Test Case 3 – Publication Details

- Open a publication from the search results.
- Verify publication information is displayed correctly.

---

### Test Case 4 – Journals Navigation

- Navigate to the **Journals** tab.
- Verify journal statistics and journal list are displayed.

---

### Test Case 5 – Journal Details

- Open a journal from the journal list.
- Verify journal details are displayed correctly.

---

### Test Case 6 – Keywords Navigation

- Navigate to the **Keywords** tab.
- Verify keyword statistics and keyword list are displayed.

---

### Test Case 7 – Keyword Details

- Open a keyword from the keyword list.
- Verify keyword analysis information is displayed.

---

### Test Case 8 – Profile Navigation

- Navigate to the **Profile** tab.
- Verify user profile information is displayed.

---

### Test Case 9 – PDF Export

- Generate a PDF report.
- Upload the report to Firebase Storage.
- Verify successful upload.

---

### Test Case 10 – Remote Config

- Retrieve Remote Config values.
- Verify configuration values are displayed.

---

### Test Case 11 – Logout

- Perform logout.
- Verify redirection to the Login screen.

### Suggested Structure

```text
patrol_tests/
│
├── authentication_test.dart
├── publication_test.dart
├── journal_test.dart
├── keyword_test.dart
├── profile_test.dart
├── export_test.dart
└── remote_config_test.dart
```

## Test documentation

Overall setup and index: **[patrol_tests/README.md](patrol_tests/README.md)**.

Per test file (command, scenario, expected result):

| Test file | Doc |
|-----------|-----|
| `authentication_test.dart` | [patrol_tests/docs/authentication_test.md](patrol_tests/docs/authentication_test.md) |
| `publication_test.dart` | [patrol_tests/docs/publication_test.md](patrol_tests/docs/publication_test.md) |
| `journal_test.dart` | [patrol_tests/docs/journal_test.md](patrol_tests/docs/journal_test.md) |
| `export_test.dart` | [patrol_tests/docs/export_test.md](patrol_tests/docs/export_test.md) |
| `logout_test.dart` | [patrol_tests/docs/logout_test.md](patrol_tests/docs/logout_test.md) |
