+------------------+
|     STUDENTS     |
+------------------+
| id               |
| first_name       |
| last_name        |
| code             |
| created_at       |
| updated_at       |
+------------------+
          |
          | 1 - n
          |
+------------------+
|     SESSIONS     |
+------------------+
| id               |
| student_id       |
| text_id          |
| duration_seconds |
| score_wpm        |
| created_at       |
| updated_at       |
+------------------+
          |
          | n - 1
          |
+------------------+
|       TEXTS      |
+------------------+
| id               |
| title            |
| content          |
| word_count       |
| created_at       |
| updated_at       |
+------------------+