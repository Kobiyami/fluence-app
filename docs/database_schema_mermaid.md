erDiagram
    STUDENT ||--o{ SESSION : has
    TEXT ||--o{ SESSION : has

    STUDENT {
      integer id
      string first_name
      string last_name
      string code
    }

    TEXT {
      integer id
      string title
      text content
      integer word_count
    }

    SESSION {
      integer id
      integer student_id
      integer text_id
      integer duration_seconds
      integer score_wpm
    }