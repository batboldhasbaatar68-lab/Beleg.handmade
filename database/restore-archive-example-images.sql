with replacements(id,old_image,new_image,note) as (values
('candle-mini','/images/sample-6.jpg','/assets/pexels-9651902.jpg','Жишээ зураг · Гаднын лааны зураг, бодит барааны хэмжээ, савлагаа биш.'),
('candle-standard','/images/sample-6.jpg','/assets/pexels-8101908.jpg','Жишээ зураг · Гаднын шилэн савтай лааны зураг, бодит бүтээгдэхүүний зураг биш.'),
('candle-large','/images/sample-6.jpg','/assets/pexels-8101908.jpg','Жишээ зураг · Гаднын шилэн савтай лааны зураг, бодит бүтээгдэхүүний хэмжээ биш.'),
('secret-box','/images/sample-3.jpg','/assets/catalog/photo-box.jpg','Жишээ загвар · AI зурагтай хайрцгийн дүрслэл. Бодит бүтээгдэхүүний зураг биш.'),
('gift-women','/images/sample-4.jpg','/assets/pexels-6831672.jpg','Жишээ зураг · Гаднын бэлгийн багцын зураг. Бодит багцын агуулгыг баталгаажуулна.'),
('gift-men','/images/sample-5.jpg','/assets/pexels-27592688.jpg','Жишээ зураг · Гаднын бэлгийн савлагаа. Бодит багцын агуулга, бүтээгдэхүүний зураг биш.'),
('open-when','/images/sample-3.jpg','/assets/catalog/letter-box.jpg','Жишээ загвар · AI захидлын хайрцгийн дүрслэл. Бодит бүтээгдэхүүний зураг биш.')
) update beleg_internal.products p set image=r.new_image,images=jsonb_build_array(r.new_image),image_note=r.note from replacements r where p.id=r.id and p.image=r.old_image and p.images=jsonb_build_array(r.old_image) and not p.real_photo and not p.deleted returning p.id,p.image,p.price,p.real_photo;