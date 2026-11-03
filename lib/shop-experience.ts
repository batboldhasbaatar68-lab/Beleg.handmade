import type {Product,Settings} from './beleg';
export type Collection={id:string;name:string;image:string;enabled:boolean;productIds:string[]};
export type Greeting={id:string;title:string;occasion:string;text:string;image:string;audio:string;enabled:boolean};
export type ShopExperience={cardShapes?:string[];freeVoiceTool?:boolean;holidays:Collection[];groups:Collection[];greetings:Greeting[]};
const img='/assets/catalog/';
const rows=[
 ['new-year','Шинэ жил','choc-bouquet.jpg','Шинэ ондоо эрүүл энх, инээд баясал, хайр дүүрэн байгаарай. Өнгөрсөн жилийн сайхан дурсамжаа нандигнаж, ирэх оны мөрөөдлөө хамтдаа бүтээе. Шинэ жилийн мэнд хүргэе!'],
 ['birthday','Төрсөн өдөр','photo-box.jpg','Төрсөн өдрийн мэнд хүргэе! Чамайг байгаагаар чинь хайрладаг хүмүүсийн дунд, өөрийнхөөрөө гэрэлтэж яваарай. Ирэх жил чинь хүсэл мөрөөдөлдөө ойртсон, аз жаргалтай өдрүүдээр дүүрэн байг.'],
 ['womens-day','Март 8','romantic-set.jpg','Эрхэмсэг сайхан танд Мартын наймны мэнд хүргэе. Өдөр бүр бусдад түгээдэг хайр, халамж тань танд хэд дахин илүү дулаахнаар эргэн ирэг. Өөртөө ч бас цаг гаргаж, инээмсэглэн жаргаарай.'],
 ['valentine','Валентин','couples-set.jpg','Чамтай учирснаас хойш энгийн өдрүүд хүртэл нандин дурсамж болсон. Хажууд минь байж, инээд гунигийг минь хуваалцдагт баярлалаа. Өнөөдөр ч, маргааш ч чамайгаа хайрлана.'],
 ['mens-day','Цэргийн баяр','wine-set.jpg','Эрхэм танд Монгол цэргийн баярын мэнд хүргэе. Гэр бүл, хайртай хүмүүстээ түшиг болж яваа таны сэтгэл, зүтгэлд талархъя. Эрүүл энх, хийморь өөдөө, хүсэл зорилго дүүрэн яваарай.'],
 ['childrens-day','Хүүхдийн баяр','choc-heart.jpg','Бяцхан од минь, хүүхдийн баярын мэнд! Инээд чинь гэр дүүргэж, мөрөөдөл чинь тэнгэрт хүрэг. Сониуч зангаа хадгалж, өдөр бүр нэг шинэ зүйл сурч, аз жаргалтай өсөөрэй.'],
 ['mothers-day','Ээжүүдийн өдөр','envelope-set.jpg','Ээж ээ, үгээр хэмжихийн аргагүй хайр, халамж бүхэнд тань баярлалаа. Ядарсан үед минь түшдэг, баярласан үед минь хамт инээдэг та минь миний хамгийн том аз. Тандаа маш их хайртай.'],
 ['anniversary','Хосын ой','letter-box.jpg','Бидний хамтдаа бүтээсэн дурсамж бүрт баярлалаа. Жижигхэн зүйлээс ч аз жаргал олж, нэгнээ сонсож, олон сайхан жилийг хамтдаа угтацгаая. Чамтайгаа байх нь миний нандин бэлэг.'],
 ['christmas','Зул сар','choc-box.jpg','Зул сарын дулаахан мэнд хүргэе. Гэр тань инээдээр, сэтгэл тань амар амгалангаар, өдөр бүхэн тань хайртай хүмүүсийн тань халуун дулаан үгсээр дүүрэн байг.'],
 ['tsagaan-sar','Цагаан сар','choc-name.jpg','Сар шинэдээ сайхан шинэлээрэй. Ахмад буурлууд минь амар амгалан, айл хотлоороо элбэг дэлбэг, ирж буй жилдээ эрүүл энх, ажил үйлс өөдрөг байхыг ерөөе.'],
 ['naadam','Үндэсний их баяр наадам','choc-custom.jpg','Дэлгэр сайхан наадмын мэнд хүргэе. Дэнж хотойтол сайхан наадаж, гэр бүл, хайртай хүмүүстэйгээ дурсамж дүүрэн өдрүүдийг өнгөрүүлээрэй. Хийморь өөдөө, сэтгэл тэнүүн байх болтугай.'],
 ['teachers-day','Багш нарын баяр','letter-box.jpg','Эрдэм мэдлэгийн замд минь хөтөлж, алдаа бүрээсээ суралцах итгэл өгсөн багш танд баярлалаа. Таны заасан хичээл, хэлсэн урмын үгс бидний амьдралд үргэлж гэрэл нэмдэг. Баярын мэнд хүргэе.'],
 ['graduation','Төгсөлтийн баяр','photo-box.jpg','Төгсөлтийн баярын мэнд хүргэе! Хичээл зүтгэлийн тань нэгэн сайхан үр дүн өнөөдөр дурсамж болж байна. Шинэ замынхаа эхэнд өөртөө итгэж, хүсэл мөрөөдөл рүүгээ зоригтой алхаарай.'],
 ['fathers-day','Аавуудын өдөр','wine-set.jpg','Аав аа, үг цөөн ч үйлдэл бүхнээрээ хайрладаг танд баярлалаа. Таны түшиг, ухаан, урмын үгс надад үргэлж хүч өгдөг. Эрүүл энх, инээд баяслаар дүүрэн байгаарай.'],
 ['wedding','Хуримын баяр','romantic-set.jpg','Хайрын тань шинэ бүлэг эхэлж буйд халуун баяр хүргэе. Нэгнээ сонсож, жижигхэн мөчүүдээ нандигнан, амар амгалан, аз жаргалтай гэр бүлийг хамтдаа бүтээгээрэй.'],
 ['housewarming','Шинэ байрны баяр','choc-box.jpg','Шинэ гэрийн баярын мэнд хүргэе! Энэ гэрт тань инээд, халуун дулаан яриа, аз жаргалтай дурсамж бүхэн цугларч байг. Гал голомт тань үргэлж өөдөө бадарч байг.']
];
const associations:Record<string,string[]>={
 'new-year':['gift-birthday','chocolate-box','qr-ai'],'birthday':['gift-birthday','photo-memory-box','qr-own'],'womens-day':['gift-women','candle-flower','qr-ai'],'valentine':['gift-love','gift-couples','love-letter-box','chocolate-heart','qr-ai'],'mens-day':['gift-men','qr-own'],'childrens-day':['chocolate-box','chocolate-flower','qr-own'],'mothers-day':['gift-women','love-letter-box','qr-ai'],'anniversary':['gift-couples','photo-memory-box','qr-ai'],'christmas':['chocolate-box','gift-love','candle-glass','qr-ai'],'tsagaan-sar':['bag-large','gift-men','gift-women','chocolate-box'],'naadam':['bag-small','chocolate-box','qr-own'],'teachers-day':['love-letter-box','gift-women','qr-ai'],'graduation':['photo-memory-box','chocolate-bouquet','qr-own'],'fathers-day':['gift-men','qr-own'],'wedding':['gift-couples','photo-memory-box','qr-ai'],'housewarming':['candle-glass','gift-birthday','qr-own']
};
export const defaultExperience:ShopExperience={
 holidays:rows.map(([id,name,image])=>({id:'holiday-'+id,name,image:img+image,enabled:true,productIds:associations[id]||[]})),
 greetings:rows.map(([id,title,image,text])=>({id:'greeting-'+id,title:title+' — мэндчилгээ',occasion:'holiday-'+id,text,image:img+image,audio:'',enabled:true})),
 groups:[
 ['women','Эмэгтэй хүнд','romantic-set.jpg',['gift-women','gift-bath','candle-flower']],
 ['men','Эрэгтэй хүнд','wine-set.jpg',['gift-men','qr-own']],
 ['couples','Хосын багц','couples-set.jpg',['gift-couples','photo-memory-box']],
 ['birthday','Төрсөн өдрийн багц','photo-box.jpg',['gift-birthday','photo-memory-box','chocolate-bouquet']],
 ['love','Романтик багц','letter-box.jpg',['gift-love','love-letter-box','chocolate-heart']],
 ['spa','Лаа, амралтын багц','romantic-set.jpg',['gift-bath','candle-bath','bath-bomb-single']],
 ['chocolate','Шоколадтай багц','choc-box.jpg',['chocolate-box','chocolate-bouquet','chocolate-custom']],
 ['memory','Захидал, дурсамж','envelope-set.jpg',['love-letter-box','love-envelope-set','photo-memory-box']],
 ].map(([id,name,image,productIds])=>({id:'group-'+id,name,image:img+image,enabled:true,productIds})) as Collection[]
};
export function getExperience(settings:Settings|null|undefined):ShopExperience{return settings?.experience||defaultExperience;}
export function collectionMatches(p:Product,id:string,settings?:Settings|null){const e=getExperience(settings);const c=[...e.holidays,...e.groups].find(x=>x.id===id);return !!c&&(p.category===id||c.productIds.includes(p.id));}
export const greetingDraftKey='beleg-greeting-draft-v1';

// Original short verse examples for the gift studio.
defaultExperience.greetings.push(...[
  {
    "id": "poem-love",
    "title": "Хайрын дөрвөн мөр",
    "occasion": "holiday-valentine",
    "text": "Харцанд чинь би гэрлээ олдог,\\nХажууд чинь өдрүүд минь дулаахан.\\nХэлж амжаагүй хайраа шингээгээд,\\nХэрхэн нандигнадагаа бэлэглэе.",
    "image": "/assets/catalog/letter-box.jpg",
    "audio": "",
    "enabled": true
  },
  {
    "id": "poem-birthday",
    "title": "Төрсөн өдрийн шүлэг",
    "occasion": "holiday-birthday",
    "text": "Шинэ насны чинь өглөө бүр\\nШинэхэн мөрөөдөлтэй учраасай.\\nИнээд, хайраар дүүрэн өдрүүд\\nИрэх жилүүдийг чинь чимээсэй.",
    "image": "/assets/catalog/letter-box.jpg",
    "audio": "",
    "enabled": true
  },
  {
    "id": "poem-mother",
    "title": "Ээждээ зориулсан шүлэг",
    "occasion": "holiday-mothers-day",
    "text": "Таны минь үг гэрэл болдог,\\nТэврэлт тань гэр минь байдаг.\\nӨдөр бүрийн таныхаа хайрыг\\nӨөрийн зүрхэндээ нандигнадаг.",
    "image": "/assets/catalog/letter-box.jpg",
    "audio": "",
    "enabled": true
  },
  {
    "id": "poem-new-year",
    "title": "Шинэ жилийн шүлэг",
    "occasion": "holiday-new-year",
    "text": "Цас бударсан шинэ ондоо\\nЦайлган хүслээ хамтдаа шивнэе.\\nӨчигдрийн сайхан дурсамжаа өвөртлөөд\\nӨглөө бүрийг итгэлээр угтая.",
    "image": "/assets/catalog/letter-box.jpg",
    "audio": "",
    "enabled": true
  }
]);
