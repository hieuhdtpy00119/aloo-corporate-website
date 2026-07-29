-- Make the investment table heading editable from the franchise CMS.
INSERT INTO franchise_contents
    (section_key, title, content, amount, note, sort_order, status)
SELECT
    'investment_header',
    'Bảng chi phí tham khảo chi tiết',
    '{"eyebrow":"Chi phí đầu tư","title":"Bảng chi phí tham khảo chi tiết","description":"Các mức chi phí mang tính tham khảo, sẽ được tư vấn cụ thể theo mặt bằng và khu vực của bạn.","footnote":"* Chi phí mang tính tham khảo, chưa bao gồm tiền thuê mặt bằng và chi phí vận hành hàng tháng."}',
    NULL,
    NULL,
    1,
    'ACTIVE'
WHERE NOT EXISTS (
    SELECT 1 FROM franchise_contents WHERE section_key = 'investment_header'
);
