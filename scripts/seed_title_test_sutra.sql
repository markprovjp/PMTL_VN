BEGIN;

-- Cleanup old seeded data
DELETE FROM sutra_glossaries_sutra_lnk
WHERE sutra_id IN (SELECT id FROM sutras WHERE slug = 'title-test')
  AND sutra_glossary_id IN (SELECT id FROM sutra_glossaries WHERE document_id LIKE 'seed-tt-glossary-%');

DELETE FROM sutra_glossaries_chapter_lnk
WHERE sutra_glossary_id IN (SELECT id FROM sutra_glossaries WHERE document_id LIKE 'seed-tt-glossary-%');

DELETE FROM sutra_glossaries_volume_lnk
WHERE sutra_glossary_id IN (SELECT id FROM sutra_glossaries WHERE document_id LIKE 'seed-tt-glossary-%');

DELETE FROM sutra_glossaries
WHERE document_id LIKE 'seed-tt-glossary-%';

DELETE FROM sutra_chapters_sutra_lnk
WHERE sutra_id IN (SELECT id FROM sutras WHERE slug = 'title-test')
  AND sutra_chapter_id IN (SELECT id FROM sutra_chapters WHERE document_id LIKE 'seed-tt-chapter-%');

DELETE FROM sutra_chapters_volume_lnk
WHERE sutra_chapter_id IN (SELECT id FROM sutra_chapters WHERE document_id LIKE 'seed-tt-chapter-%');

DELETE FROM sutra_chapters
WHERE document_id LIKE 'seed-tt-chapter-%';

DELETE FROM sutra_volumes_sutra_lnk
WHERE sutra_id IN (SELECT id FROM sutras WHERE slug = 'title-test')
  AND sutra_volume_id IN (SELECT id FROM sutra_volumes WHERE document_id LIKE 'seed-tt-volume-%');

DELETE FROM sutra_volumes
WHERE document_id LIKE 'seed-tt-volume-%';

DROP TABLE IF EXISTS tmp_tt_volume_src;
DROP TABLE IF EXISTS tmp_tt_volumes;
DROP TABLE IF EXISTS tmp_tt_chapter_src;
DROP TABLE IF EXISTS tmp_tt_chapters;
DROP TABLE IF EXISTS tmp_tt_glossary_src;
DROP TABLE IF EXISTS tmp_tt_glossaries;

CREATE TEMP TABLE tmp_tt_volume_src AS
SELECT *
FROM (VALUES
  (1, 'Tập 1: Nhập Môn Hành Trì', 'title-test-tap-1', 1, 120, 'Nền tảng về chánh kiến, chánh niệm và nếp sống tỉnh thức.', 'seed-tt-volume-1'),
  (2, 'Tập 2: Thực Hành Trong Đời Sống', 'title-test-tap-2', 121, 240, 'Ứng dụng giáo pháp trong công việc, gia đình và cộng đồng.', 'seed-tt-volume-2'),
  (3, 'Tập 3: Quán Chiếu Và Chuyển Hóa', 'title-test-tap-3', 241, 360, 'Đào sâu quán chiếu khổ, vô thường và nuôi dưỡng lòng từ.', 'seed-tt-volume-3')
) AS t(volume_number, title, slug, book_start, book_end, description, document_id);

INSERT INTO sutra_volumes (
  document_id, title, slug, volume_number, book_start, book_end, description,
  sort_order, created_at, updated_at, published_at, locale
)
SELECT
  document_id,
  title,
  slug,
  volume_number,
  book_start,
  book_end,
  description,
  volume_number,
  NOW(), NOW(), NOW(), 'vi'
FROM tmp_tt_volume_src;

CREATE TEMP TABLE tmp_tt_volumes AS
SELECT sv.id, src.volume_number, src.document_id
FROM sutra_volumes sv
JOIN tmp_tt_volume_src src ON src.document_id = sv.document_id;

INSERT INTO sutra_volumes_sutra_lnk (sutra_volume_id, sutra_id, sutra_volume_ord)
SELECT tv.id, s.id, tv.volume_number::double precision
FROM tmp_tt_volumes tv
CROSS JOIN LATERAL (
  SELECT id FROM sutras WHERE slug = 'title-test' ORDER BY id DESC LIMIT 1
) s;

CREATE TEMP TABLE tmp_tt_chapter_src AS
SELECT
  g.volume_number,
  g.chapter_no,
  g.global_no,
  format('seed-tt-chapter-v%s-c%s', g.volume_number, lpad(g.chapter_no::text, 2, '0')) AS document_id,
  format('Phẩm %s: %s', lpad(g.global_no::text, 2, '0'),
    CASE (g.global_no % 6)
      WHEN 0 THEN 'An Trú Hơi Thở'
      WHEN 1 THEN 'Chánh Niệm Thân Tâm'
      WHEN 2 THEN 'Từ Bi Trong Ứng Xử'
      WHEN 3 THEN 'Quán Vô Thường'
      WHEN 4 THEN 'Buông Xả Phiền Não'
      ELSE 'Hành Trì Giữa Đời Thường'
    END
  ) AS title,
  format('title-test-pham-%s', lpad(g.global_no::text, 2, '0')) AS slug,
  format('Mở đầu phẩm %s: người học khởi tâm cung kính, trở về hơi thở và thân hành hiện tại.', g.global_no) AS opening_text,
  format(
    'Đoạn 1 phẩm %s: hành giả giữ thân ngay thẳng, nhận biết rõ từng hơi thở vào ra (1).\n\nĐoạn 2 phẩm %s: khi vọng tưởng sinh khởi, chỉ ghi nhận và quay lại [[Chánh niệm]] trong từng bước nhỏ (2).\n\nĐoạn 3 phẩm %s: nuôi lớn tâm từ bằng lời nói ái ngữ, hành động lợi ích và thái độ biết ơn (3).\n\nĐoạn 4 phẩm %s: quán chiếu [[Vô thường]] để giảm chấp trước, từ đó phát sinh bình an và trí tuệ.',
    g.global_no, g.global_no, g.global_no, g.global_no
  ) AS content,
  format('Kết phẩm %s: giữ một niệm thiện lành, đem sự an tĩnh ứng dụng vào gia đình và công việc.', g.global_no) AS ending_text,
  8 + (g.global_no % 5) AS estimated_read_minutes,
  g.global_no AS sort_order
FROM (
  SELECT
    v.volume_number,
    c.chapter_no,
    ((v.volume_number - 1) * 8 + c.chapter_no) AS global_no
  FROM (SELECT generate_series(1,3) AS volume_number) v
  CROSS JOIN (SELECT generate_series(1,8) AS chapter_no) c
) g;

INSERT INTO sutra_chapters (
  document_id, title, slug, chapter_number, opening_text, content, ending_text,
  estimated_read_minutes, sort_order, created_at, updated_at, published_at, locale
)
SELECT
  document_id,
  title,
  slug,
  chapter_no,
  opening_text,
  content,
  ending_text,
  estimated_read_minutes,
  sort_order,
  NOW(), NOW(), NOW(), 'vi'
FROM tmp_tt_chapter_src;

CREATE TEMP TABLE tmp_tt_chapters AS
SELECT sc.id, src.volume_number, src.global_no, src.document_id
FROM sutra_chapters sc
JOIN tmp_tt_chapter_src src ON src.document_id = sc.document_id;

INSERT INTO sutra_chapters_sutra_lnk (sutra_chapter_id, sutra_id)
SELECT tc.id, s.id
FROM tmp_tt_chapters tc
CROSS JOIN LATERAL (
  SELECT id FROM sutras WHERE slug = 'title-test' ORDER BY id DESC LIMIT 1
) s;

INSERT INTO sutra_chapters_volume_lnk (sutra_chapter_id, sutra_volume_id, sutra_chapter_ord)
SELECT tc.id, tv.id, tc.global_no::double precision
FROM tmp_tt_chapters tc
JOIN tmp_tt_volumes tv ON tv.volume_number = tc.volume_number;

CREATE TEMP TABLE tmp_tt_glossary_src AS
SELECT *
FROM (VALUES
  ('seed-tt-glossary-01', '1', 'Hơi thở chánh niệm', 'Thở vào biết rõ thở vào, thở ra biết rõ thở ra, tâm không tán loạn.', 1),
  ('seed-tt-glossary-02', '2', 'Chánh niệm', 'Năng lực nhận biết rõ ràng những gì đang diễn ra trong thân tâm ngay hiện tại.', 2),
  ('seed-tt-glossary-03', '3', 'Tâm từ', 'Tình thương rộng mở, mong mình và người đều an vui, bớt khổ.', 3),
  ('seed-tt-glossary-04', 'tt-04', 'Vô thường', 'Mọi pháp đều biến đổi không ngừng, không có gì cố định mãi mãi.', 4),
  ('seed-tt-glossary-05', 'tt-05', 'Buông xả', 'Tháo gỡ dính mắc để tâm được nhẹ nhàng, sáng suốt.', 5),
  ('seed-tt-glossary-06', 'tt-06', 'Ái ngữ', 'Lời nói chân thành, êm dịu, giúp nuôi dưỡng sự hiểu biết và hòa hợp.', 6),
  ('seed-tt-glossary-07', 'tt-07', 'Tỉnh giác', 'Sự sáng tỏ, biết mình đang làm gì, nói gì, nghĩ gì.', 7),
  ('seed-tt-glossary-08', 'tt-08', 'Nhẫn nại', 'Khả năng chịu đựng và chuyển hóa khó khăn mà không sân hận.', 8),
  ('seed-tt-glossary-09', 'tt-09', 'Thiểu dục', 'Giảm bớt ham muốn không cần thiết để sống thảnh thơi.', 9),
  ('seed-tt-glossary-10', 'tt-10', 'Tri túc', 'Biết đủ, trân trọng những gì đang có, không chạy theo bất tận.', 10),
  ('seed-tt-glossary-11', 'tt-11', 'Quán chiếu', 'Nhìn sâu vào nguyên nhân và điều kiện để thấy đúng bản chất sự việc.', 11),
  ('seed-tt-glossary-12', 'tt-12', 'Chuyển hóa', 'Biến đổi tập khí khổ đau thành hiểu biết và tình thương.', 12)
) AS t(document_id, marker_key, term, meaning, sort_order);

INSERT INTO sutra_glossaries (
  document_id, marker_key, term, meaning, sort_order,
  created_at, updated_at, published_at, locale
)
SELECT
  document_id,
  marker_key,
  term,
  meaning,
  sort_order,
  NOW(), NOW(), NOW(), 'vi'
FROM tmp_tt_glossary_src;

CREATE TEMP TABLE tmp_tt_glossaries AS
SELECT sg.id, src.sort_order, src.document_id
FROM sutra_glossaries sg
JOIN tmp_tt_glossary_src src ON src.document_id = sg.document_id;

INSERT INTO sutra_glossaries_sutra_lnk (sutra_glossary_id, sutra_id, sutra_glossary_ord)
SELECT tg.id, s.id, tg.sort_order::double precision
FROM tmp_tt_glossaries tg
CROSS JOIN LATERAL (
  SELECT id FROM sutras WHERE slug = 'title-test' ORDER BY id DESC LIMIT 1
) s;

COMMIT;
