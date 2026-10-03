import Foundation

typealias Restaurant = Components.Schemas.Restaurant
extension Restaurant: Identifiable {}

typealias Prompt = Components.Schemas.Answer.PromptPayload
extension Prompt {

    var title: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

#if DEBUG
    extension Restaurant {

        static let samples: [Restaurant] = {
            struct Page: Decodable {
                let data: [Restaurant]
            }
            return try! JSONDecoder()
                .decode(Page.self, from: Data(restaurants.utf8))
                .data
        }()

        static let sample = samples[0]
    }

    private let restaurants = #"""
        {
          "data": [
            {
              "id": "01a0f27d-836d-79ca-95f2-a4d79ba71fea",
              "name": "LIFETASTIC Patisserie",
              "category": "Bakery",
              "address": "Kiosk C, LG2/F, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "Coconut cake 「斑斕椰香蛋糕」 — a summer must-eat new item with fresh sweet flavour that isn't cloying.",
                  "source_url": "https://www.instagram.com/p/DWVrEpFFM_8"
                },
                {
                  "prompt": "getting_there",
                  "text": "Kowloon Tong Station Exit C2.",
                  "source_url": "https://www.lifetastichk.com/en/stores"
                },
                {
                  "prompt": "how_old",
                  "text": "At least 10 years old — the brand released a 10th-anniversary fruit cake.",
                  "source_url": "https://www.instagram.com/p/DWVrEpFFM_8"
                },
                {
                  "prompt": "drinks",
                  "text": "Coffee — the venue operates as a coffee shop.",
                  "source_url": "https://www.facebook.com/pages/Lifetastic-Patisserie/497198287508196"
                },
                {
                  "prompt": "known_for",
                  "text": "A patisserie/bread shop — TripAdvisor confirms it is mainly a bakery.",
                  "source_url": "https://www.tripadvisor.com.tw/Restaurant_Review-g294217-d23583447-Reviews-LIFETASTIC_Patisserie_Festival_Walk-Hong_Kong.html"
                }
              ],
              "price_level": null,
              "lat": 22.337077,
              "lon": 114.174788
            },
            {
              "id": "01a0f27d-836e-7b02-9936-317cff6019eb",
              "name": "Tea WG Salon & Boutique",
              "category": "Tea Room",
              "address": "Shop LG2-11, LG2/F, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "Tea Teddies — eight varieties of juicy bear-shaped treats made with a base of Tea WG white tea, one of the world's most precious teas",
                  "source_url": "https://www.openrice.com/en/hongkong/r-tea-wg-salon-boutique-kowloon-tong-western-r631312"
                },
                {
                  "prompt": "what_to_order_first",
                  "text": "Pan-fried Wagyu beef burger with matcha powder fries",
                  "source_url": "https://www.openrice.com/en/hongkong/r-tea-wg-salon-boutique-kowloon-tong-western-r631312"
                },
                {
                  "prompt": "drinks",
                  "text": "Tea Teddies can be dropped into hot water to become a charming cup of tea with the crystal sugar stick already melted in",
                  "source_url": "https://www.openrice.com/en/hongkong/r-tea-wg-salon-boutique-kowloon-tong-western-r631312"
                },
                {
                  "prompt": "getting_there",
                  "text": "Four-minute walk from Exit C2 of Kowloon Tong MTR Station",
                  "source_url": "https://www.openrice.com/en/hongkong/r-tea-wg-salon-boutique-kowloon-tong-western-r631312"
                },
                {
                  "prompt": "known_for",
                  "text": "Tea Teddies are crafted with Tea WG white tea as a base note, one of the most precious and coveted tea varieties in the world",
                  "source_url": "https://www.openrice.com/en/hongkong/r-tea-wg-salon-boutique-kowloon-tong-western-r631312"
                }
              ],
              "price_level": null,
              "lat": 22.336991,
              "lon": 114.174746
            },
            {
              "id": "01a0f27d-836e-7cee-b739-70fe703d843f",
              "name": "Garrett Popcorn Shops 皆樂爆谷",
              "category": "Snack Place",
              "address": "Shop UG-24, UG/F, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "Garrett Mix (Chicago Mix) – the signature blend of caramel and cheese popcorn",
                  "source_url": "https://news.now.com/watch/content/garrett-popcorn%E7%88%86%E8%B0%B7%E5%BA%97%E6%92%A4%E5%87%BA%E9%A6%99%E6%B8%AF%EF%BC%81%E3%80%80%E5%85%A8%E7%B7%9A6%E5%88%86%E5%BA%97%E6%9C%AC%E6%9C%88%E7%B5%90%E6%A5%AD"
                },
                {
                  "prompt": "known_for",
                  "text": "Handmade in small batches daily using traditional copper kettles and non-GMO butterfly/mushroom kernels",
                  "source_url": "https://www.weekendhk.com/%E9%A3%B2%E9%A3%9F%E7%86%B1%E8%A9%B1/garrett-popcorn-%E7%B5%90%E6%A5%AD-%E7%88%86%E8%B0%B7%E5%BA%97-aplt2-ww01-992995"
                },
                {
                  "prompt": "how_old",
                  "text": "Founded in 1949 in Chicago (75-year history), entered Hong Kong in 2011 as first Asian market",
                  "source_url": "https://www.weekendhk.com/%E9%A3%B2%E9%A3%9F%E7%86%B1%E8%A9%B1/garrett-popcorn-%E7%B5%90%E6%A5%AD-%E7%88%86%E8%B0%B7%E5%BA%97-aplt2-ww01-992995"
                },
                {
                  "prompt": "getting_there",
                  "text": "MTR Kowloon Tong Station, Festival Walk exit",
                  "source_url": "https://livingpassbook.wordpress.com/2015/02/06/garrett-popcorn-hk-%E5%85%A8%E4%B8%96%E7%95%8C%E6%9C%80%E6%9C%83%E8%A1%8C%E9%8A%B7%E7%9A%84%E7%88%86%E7%B1%B3%E8%8A%B1"
                },
                {
                  "prompt": "value_for_money",
                  "text": "CaramelCrisp and Garrett Mix offered for HK$50",
                  "source_url": "https://www.facebook.com/GarrettPopcorn/videos/yes-you-should-have-garrett-now/991348740008762"
                }
              ],
              "price_level": null,
              "lat": 22.3372621124444,
              "lon": 114.174581011053
            },
            {
              "id": "01a0f27d-836f-7133-96ff-af3695d146c2",
              "name": "Cova Ristorante & Caffe",
              "category": "Italian Restaurant",
              "address": "達之路80號又一城 lg1層11號舖",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "The signature chocolate series 「朱古力系列」 is the must-try.",
                  "source_url": "https://www.weekendhk.com/restaurant/covaristorantecaffe%E5%8F%88%E4%B8%80%E5%9F%8E-%E4%B9%9D%E9%BE%8D%E5%A1%98-3347596"
                },
                {
                  "prompt": "order_this_not_that",
                  "text": "Order the pan-fried salmon 「三文魚」 instead of the gelato—the salmon is tender and fresh, while the gelato is just average.",
                  "source_url": "https://www.instagram.com/p/CM8iLzshdWX"
                },
                {
                  "prompt": "room_vibe",
                  "text": "Elegant and comfortable, blending traditional Italian coffee culture with a modern urban vibe—ideal for a relaxed afternoon tea with a few friends.",
                  "source_url": "https://www.weekendhk.com/restaurant/covaristorantecaffe%E5%8F%88%E4%B8%80%E5%9F%8E-%E4%B9%9D%E9%BE%8D%E5%A1%98-3347596"
                },
                {
                  "prompt": "known_for",
                  "text": "A 200-year-old Italian coffee brand, with this branch regarded as Hong Kong’s best for authentic coffee craftsmanship.",
                  "source_url": "https://www.weekendhk.com/restaurant/covaristorantecaffe%E5%8F%88%E4%B8%80%E5%9F%8E-%E4%B9%9D%E9%BE%8D%E5%A1%98-3347596"
                },
                {
                  "prompt": "drinks",
                  "text": "The Italian coffee 「意式咖啡」 is expertly made with rich aroma and proper concentration.",
                  "source_url": "https://www.weekendhk.com/restaurant/covaristorantecaffe%E5%8F%88%E4%B8%80%E5%9F%8E-%E4%B9%9D%E9%BE%8D%E5%A1%98-3347596"
                }
              ],
              "price_level": 4,
              "lat": 22.337262,
              "lon": 114.174688
            },
            {
              "id": "01a0f27d-836f-7246-9b39-0b9d70620f72",
              "name": "王家沙",
              "category": "Chinese Restaurant",
              "address": "達之路80號又一城 g層23號舖",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "The signature crab roe xiao long bao 「招牌蟹粉小籠包」 is famous for its juicy, flavourful filling.",
                  "source_url": "https://www.openrice.com/zh/hongkong/r-%E7%8E%8B%E5%AE%B6%E6%B2%99-%E8%8A%B1%E6%A8%A3%E5%B9%B4%E8%8F%AF-%E4%B9%9D%E9%BE%8D%E5%A1%98-%E6%BB%AC%E8%8F%9C-%E4%B8%AD%E6%B5%B7-r659477/menus"
                },
                {
                  "prompt": "what_to_order_first",
                  "text": "Start with the Su-style fresh meat xiao long bao 「蘇式鮮肉小籠包」.",
                  "source_url": "https://www.openrice.com/zh/hongkong/r-%E7%8E%8B%E5%AE%B6%E6%B2%99-%E8%8A%B1%E6%A8%A3%E5%B9%B4%E8%8F%AF-%E4%B9%9D%E9%BE%8D%E5%A1%98-%E6%BB%AC%E8%8F%9C-%E4%B8%AD%E6%B5%B7-r659477/menus"
                },
                {
                  "prompt": "known_for",
                  "text": "It holds the reputation of 'Shanghai Dim Sum Champion' 「上海點心狀元」.",
                  "source_url": "https://zh.wikipedia.org/zh-hant/%E7%8E%8B%E5%AE%B6%E6%B2%99%E7%82%B9%E5%BF%83%E5%BA%97"
                },
                {
                  "prompt": "getting_there",
                  "text": "Take MTR Kowloon Tong Station Exit C2 or H.",
                  "source_url": "https://www.getreadyhk.com/lifestyle/restaurants/item/3082-bloom-by-wang-jia-sha"
                },
                {
                  "prompt": "how_old",
                  "text": "The restaurant traces its roots back to 1945.",
                  "source_url": "https://www.getreadyhk.com/lifestyle/restaurants/item/3082-bloom-by-wang-jia-sha"
                }
              ],
              "price_level": 3,
              "lat": 22.337262,
              "lon": 114.174688
            },
            {
              "id": "01a0f27d-836f-77e6-b94b-4909cee24da3",
              "name": "Amaroni's",
              "category": "Italian Restaurant",
              "address": "Shop LG-132, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "Tiramisu is a main dish here.",
                  "source_url": "https://www.openrice.com/zh/hongkong/r-amaronis-kowloon-tong-italian-salad-r61/videos/reels/video-19087"
                },
                {
                  "prompt": "room_vibe",
                  "text": "The room has a stylish vibe with spacious, comfortable seating.",
                  "source_url": "https://maps.apple.com/place?auid=1773016951404243284&lsp=9902"
                },
                {
                  "prompt": "service",
                  "text": "Staff are very polite and have a great service attitude.",
                  "source_url": "https://maps.apple.com/place?auid=1773016951404243284&lsp=9902"
                },
                {
                  "prompt": "portion_size",
                  "text": "Portions are large; the Classic Crispy Appetizers Combo comes on a big plate.",
                  "source_url": "https://maps.apple.com/place?auid=1773016951404243284&lsp=9902"
                },
                {
                  "prompt": "known_for",
                  "text": "They make everything fresh by hand daily.",
                  "source_url": "https://www.facebook.com/amaronis"
                }
              ],
              "price_level": null,
              "lat": 22.3372657680148,
              "lon": 114.174650501679
            },
            {
              "id": "01a0f27d-836f-7dfb-a26f-8c1aebcf2fdf",
              "name": "Dan Ryan's Chicago Grill",
              "category": "American Restaurant",
              "address": "Shop LG2-28, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "Ryan's Reuben sandwich",
                  "source_url": "https://grokipedia.com/page/Dan_Ryans_Chicago_Grill"
                },
                {
                  "prompt": "known_for",
                  "text": "They bake fresh bread, muffins, and cakes in-house every morning.",
                  "source_url": "https://grokipedia.com/page/Dan_Ryans_Chicago_Grill"
                },
                {
                  "prompt": "portion_size",
                  "text": "Portions are generously sized, American-style.",
                  "source_url": "https://grokipedia.com/page/Dan_Ryans_Chicago_Grill"
                },
                {
                  "prompt": "room_vibe",
                  "text": "Casual, family-friendly atmosphere.",
                  "source_url": "https://grokipedia.com/page/Dan_Ryans_Chicago_Grill"
                },
                {
                  "prompt": "how_old",
                  "text": "Been around since 1989.",
                  "source_url": "https://grokipedia.com/page/Dan_Ryans_Chicago_Grill"
                }
              ],
              "price_level": null,
              "lat": 22.3372844485739,
              "lon": 114.174628165447
            },
            {
              "id": "01a0f27d-836f-7f45-bf78-307959ab93c5",
              "name": "八月花",
              "category": "Chinese Restaurant",
              "address": "達之路80號又一城 g層25號舖",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "The must-try is the Malay-style sour soup fish fillet with salt-and-pepper fresh abalone radish cake 「馬來酸湯浸鮮魚柳+椒鹽鮮鮑魚蘿蔔糕」.",
                  "source_url": "https://holidaysmart.io/hk/article/416610/%E5%85%AB%E6%9C%88%E8%8A%B1%E5%85%A8%E6%96%B0%E8%8F%9C%E5%96%AE%EF%BD%9C%E8%BF%9120%E6%AC%BE%E7%B2%BE%E7%B7%BB%E8%8F%9C%E5%BC%8F%EF%BC%81%E5%BF%85%E9%A3%9F%E9%A6%AC%E4%BE%86%E9%85%B8%E6%B9%AF%E6%B5%B8"
                },
                {
                  "prompt": "what_to_order_first",
                  "text": "Start with the Spanish hand-grabbed pepper pork ribs 「西班牙手抓胡椒豬肋排」.",
                  "source_url": "https://holidaysmart.io/hk/article/416610/%E5%85%AB%E6%9C%88%E8%8A%B1%E5%85%A8%E6%96%B0%E8%8F%9C%E5%96%AE%EF%BD%9C%E8%BF%9120%E6%AC%BE%E7%B2%BE%E7%B7%BB%E8%8F%9C%E5%BC%8F%EF%BC%81%E5%BF%85%E9%A3%9F%E9%A6%AC%E4%BE%86%E9%85%B8%E6%B9%AF%E6%B5%B8"
                },
                {
                  "prompt": "what_to_skip",
                  "text": "Skip the oil chicken 「油鸡」 – it’s just average.",
                  "source_url": "https://www.weekendhk.com/restaurant/%E5%85%AB%E6%9C%88%E8%8A%B1-%E4%B9%9D%E9%BE%8D%E5%A1%98-%E4%B8%AD%E8%8F%9C-%E7%B2%B5%E8%8F%9C-%E5%8D%88%E9%A4%90-%E6%99%9A%E9%A4%90-%E9%85%92%E6%A8%93-%E9%BB%9E%E5%BF%83-%E4%B8%8B%E5%8D%88%E8%8C%B6-2905810"
                },
                {
                  "prompt": "room_vibe",
                  "text": "The dining room is decked out in red with wide table spacing and a tea menu that reads like a picture book.",
                  "source_url": "http://sunny1948.blogspot.com/2013/10/jasmine-garden.html"
                },
                {
                  "prompt": "known_for",
                  "text": "They serve dim sum three pieces per basket, one basket per person.",
                  "source_url": "https://www.weekendhk.com/restaurant/%E5%85%AB%E6%9C%88%E8%8A%B1-%E4%B9%9D%E9%BE%8D%E5%A1%98-%E4%B8%AD%E8%8F%9C-%E7%B2%B5%E8%8F%9C-%E5%8D%88%E9%A4%90-%E6%99%9A%E9%A4%90-%E9%85%92%E6%A8%93-%E9%BB%9E%E5%BF%83-%E4%B8%8B%E5%8D%88%E8%8C%B6-2905810"
                }
              ],
              "price_level": null,
              "lat": 22.337363,
              "lon": 114.174598
            },
            {
              "id": "01a0f27d-836f-7fee-9a35-b7eb40dc0be8",
              "name": "EXP",
              "category": "Restaurant",
              "address": "Unit UG-23, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "The pizza is especially tasty.",
                  "source_url": "https://www.tripadvisor.com.tw/Restaurant_Review-g294217-d1010399-Reviews-EXP-Hong_Kong.html"
                },
                {
                  "prompt": "known_for",
                  "text": "It serves new-style light meals like noodles, pizza, sandwiches and rice dishes with novel toppings, right next to an ice rink.",
                  "source_url": "https://www.discoverhongkong.com/tc/travel-guide/qts/restaurants-results/restaurants-details.id11052.exp.html"
                },
                {
                  "prompt": "room_vibe",
                  "text": "Dining next to the ice rink gives a cool, refreshing vibe.",
                  "source_url": "https://www.discoverhongkong.com/tc/travel-guide/qts/restaurants-results/restaurants-details.id11052.exp.html"
                },
                {
                  "prompt": "drinks",
                  "text": "New milkshakes and desserts have been added.",
                  "source_url": "https://www.facebook.com/FestivalWalk/posts/exp-%E4%BB%A5%E5%85%A8%E6%96%B0%E9%9D%A2%E8%B2%8C%E7%99%BB%E5%A0%B4%E4%BB%A5%E6%9C%9D%E6%B0%A3%E6%B4%BB%E5%8A%9B%E6%84%9F%E8%A5%AF%E6%89%98%E6%96%B0%E6%AC%BE%E6%BB%8B%E5%91%B3exp%E6%8F%9B%E4%B8%8A%E5%85%A8%E6%96%B0%E9%9D%A2%E8%B2%8C%E7%99%BB%E5%A0%B4%E6%9B%B4%E5%B0%87%E5%89%B5%E6%84%8F%E7%BE%8E%E9%A3%9F%E9%A3%B2%E9%A3%9F%E7%9A%84%E8%A6%81%E6%B1%82%E4%BD%8D%E8%99%95%E9%A4%90%E5%BB%B3%E5%85%A5%E5%8F%A3%E7%9A%84%E5%A4%A7%E5%9E%8B%E9%9B%BB%E5%AD%90/680895867504700"
                }
              ],
              "price_level": null,
              "lat": 22.3373952038,
              "lon": 114.174240934869
            },
            {
              "id": "01a0f27d-8370-7086-98f9-abce8adbad6b",
              "name": "An Nam",
              "category": "Vietnamese Restaurant",
              "address": "Shop L1-20, Level 1, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "An Nam snack platter 「安南小食拼盤」 with steamed rice rolls, spring rolls, Vietnamese shrimp cakes, soft-shell crab rice noodle rolls, and crispy fresh shrimp chips",
                  "source_url": "https://www.tripadvisor.com.tw/Restaurant_Review-g294217-d9593928-Reviews-An_Nam_Festival_Walk-Hong_Kong.html"
                },
                {
                  "prompt": "order_this_if_its_your_second_time",
                  "text": "An Nam sour crab 「安南酸子蟹」 at $548 with ample portion",
                  "source_url": "https://www.tripadvisor.com.tw/Restaurant_Review-g294217-d9593928-Reviews-An_Nam_Festival_Walk-Hong_Kong.html"
                },
                {
                  "prompt": "portion_size",
                  "text": "The sour crab has ample portion (份量十足)",
                  "source_url": "https://www.tripadvisor.com.tw/Restaurant_Review-g294217-d9593928-Reviews-An_Nam_Festival_Walk-Hong_Kong.html"
                },
                {
                  "prompt": "known_for",
                  "text": "Known as a good venue for large group events",
                  "source_url": "https://cn.tripadvisor.com/Restaurant_Review-g294217-d9593928-Reviews-or30-An_Nam_Festival_Walk-Hong_Kong.html"
                }
              ],
              "price_level": null,
              "lat": 22.3374066084956,
              "lon": 114.174066622367
            },
            {
              "id": "01a0f27d-8370-7108-b10e-ac2e053ca948",
              "name": "J.S. Foodies Tokyo",
              "category": "Café",
              "address": "LG2-30, Festival Walk",
              "area": "Sham Shui Po",
              "answers": [],
              "price_level": null,
              "lat": 22.337422,
              "lon": 114.174094
            },
            {
              "id": "01a0f27d-8370-7309-9b1b-d4aa8ef6c35c",
              "name": "Queen's Café",
              "category": "Café",
              "address": "Shop L1-18, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "Borscht soup",
                  "source_url": "https://hedonisthk.blogspot.com/2020/12/queens-cafe-hong-kong-china.html"
                },
                {
                  "prompt": "known_for",
                  "text": "Local twist on western dishes, especially Russian cuisine",
                  "source_url": "https://hedonisthk.blogspot.com/2020/12/queens-cafe-hong-kong-china.html"
                },
                {
                  "prompt": "how_old",
                  "text": "This branch opened in 1998",
                  "source_url": "https://www.orangenews.hk/mycookey/1189173/%E5%8F%88%E4%B8%80%E5%9F%8E%E7%9A%87%E5%90%8E%E9%A4%90%E5%BB%B3%E5%85%89%E6%A6%AE%E7%B5%90%E6%A5%AD-%E9%A3%9F%E5%AE%A2%E4%B8%8D%E6%8D%A8-%E6%B1%AA%E6%98%8E%E8%8D%83%E9%84%A7%E6%A2%93%E5%B3%B0%E8%A1%9D%E5%88%BA%E8%B6%95%E7%95%99%E5%BF%B5"
                },
                {
                  "prompt": "getting_there",
                  "text": "Exit C2 or H from Kowloon Tong MTR Station",
                  "source_url": "https://www.openrice.com/en/hongkong/r-queens-cafe-kowloon-tong-eastern-europe-r2841"
                }
              ],
              "price_level": 4,
              "lat": 22.3373847780781,
              "lon": 114.174196529836
            },
            {
              "id": "01a0f27d-8370-757a-aef4-4a39f85ef7a7",
              "name": "Tonkichi",
              "category": "Japanese Restaurant",
              "address": "",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "The signature dish is deep-sea prawn 「吉列深海大蝦」.",
                  "source_url": "https://tonkichi.com.hk"
                },
                {
                  "prompt": "known_for",
                  "text": "It's known as Hong Kong's first and only high-class Japanese tonkatsu specialist since 1995.",
                  "source_url": "https://tonkichi.com.hk"
                },
                {
                  "prompt": "how_old",
                  "text": "They've been around since 1995.",
                  "source_url": "https://tonkichi.com.hk"
                },
                {
                  "prompt": "need_to_book",
                  "text": "You need to book at least 2 hours ahead.",
                  "source_url": "https://tonkichi.com.hk/Reservation.html"
                }
              ],
              "price_level": null,
              "lat": 22.337436,
              "lon": 114.174193
            },
            {
              "id": "01a0f27d-8370-7948-8f60-bb5a52e65d6a",
              "name": "The Orbit Cafe @Saloon",
              "category": "Coffee Shop",
              "address": "達之路80號又一城LG2樓LG2-23號舖",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "known_for",
                  "text": "French slow-cooked food cafe concept headed by French blue-ribbon chef Eric Wong with over 10 years of French restaurant experience.",
                  "source_url": "https://www.instagram.com/theorbit.cafe"
                },
                {
                  "prompt": "room_vibe",
                  "text": "Hidden inside a hair salon; relaxed, low-key environment.",
                  "source_url": "https://blog.ulifestyle.com.hk/article/likkolifelog/4293324/%E4%B9%9D%E9%BE%8D%E5%A1%98-the-orbit-cafe-saloon-%E6%9A%97%E8%97%8F%E9%AB%AE%E5%9E%8B%E5%B1%8B%E5%85%A7%E7%9A%84%E5%A5%BD%E5%9C%B0%E6%96%B9"
                },
                {
                  "prompt": "drinks",
                  "text": "Free drink included with each meal; Happy Hour offered.",
                  "source_url": "https://blog.ulifestyle.com.hk/article/likkolifelog/4293324/%E4%B9%9D%E9%BE%8D%E5%A1%98-the-orbit-cafe-saloon-%E6%9A%97%E8%97%8F%E9%AB%AE%E5%9E%8B%E5%B1%8B%E5%85%A7%E7%9A%84%E5%A5%BD%E5%9C%B0%E6%96%B9"
                },
                {
                  "prompt": "best_dish",
                  "text": "Truffle mashed potatoes with French bread, served with complimentary appetizer and drink.",
                  "source_url": "https://blog.ulifestyle.com.hk/article/likkolifelog/4293324/%E4%B9%9D%E9%BE%8D%E5%A1%98-the-orbit-cafe-saloon-%E6%9A%97%E8%97%8F%E9%AB%AE%E5%9E%8B%E5%B1%8B%E5%85%A7%E7%9A%84%E5%A5%BD%E5%9C%B0%E6%96%B9"
                },
                {
                  "prompt": "getting_there",
                  "text": "Located at 80 Tat Chee Avenue, Kowloon Tong; walk from Kowloon City area.",
                  "source_url": "https://coffee-hk.com/places/the-orbit-cafe-saloon"
                }
              ],
              "price_level": 2,
              "lat": 22.33745,
              "lon": 114.17421
            },
            {
              "id": "01a0f27d-8370-7d91-b125-77193f321267",
              "name": "simplylife",
              "category": "Café",
              "address": "Festival Walk, L2-30 Festival Walk",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "order_this_not_that",
                  "text": "Order the black truffle wide noodles instead of the burger — the noodles are tasty but the burger has overcooked, salty beef and hard bread.",
                  "source_url": "https://cn.tripadvisor.com/Restaurant_Review-g294217-d1436686-Reviews-or60-Simplylife_Bakery_Cafe_Festival_Walk-Hong_Kong.html"
                },
                {
                  "prompt": "what_to_skip",
                  "text": "Skip the burger — the beef is overcooked, too salty, and hard to cut through.",
                  "source_url": "https://cn.tripadvisor.com/Restaurant_Review-g294217-d1436686-Reviews-or60-Simplylife_Bakery_Cafe_Festival_Walk-Hong_Kong.html"
                },
                {
                  "prompt": "room_vibe",
                  "text": "The interior design is nice but it gets noisy since it's inside a large plaza; good for small gatherings.",
                  "source_url": "https://cn.tripadvisor.com/Restaurant_Review-g294217-d1436686-Reviews-or60-Simplylife_Bakery_Cafe_Festival_Walk-Hong_Kong.html"
                },
                {
                  "prompt": "portion_size",
                  "text": "The black truffle wide noodles come in a small portion.",
                  "source_url": "https://cn.tripadvisor.com/Restaurant_Review-g294217-d1436686-Reviews-or60-Simplylife_Bakery_Cafe_Festival_Walk-Hong_Kong.html"
                },
                {
                  "prompt": "value_for_money",
                  "text": "Mains include a drink and bread, but soup, salad, and dessert cost extra, making it slightly pricey.",
                  "source_url": "https://cn.tripadvisor.com/Restaurant_Review-g294217-d1436686-Reviews-or60-Simplylife_Bakery_Cafe_Festival_Walk-Hong_Kong.html"
                }
              ],
              "price_level": 3,
              "lat": 22.337555,
              "lon": 114.17415
            },
            {
              "id": "01a0f27d-8370-7f24-a662-f34ca4cab7ed",
              "name": "Arte By Padaria",
              "category": "Bakery",
              "address": "80號 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "Flowing heart black chocolate croissant ball (流心黑朱古力可頌球) is a signature item.",
                  "source_url": "https://www.openrice.com/zh/hongkong/r-arte-by-padaria-%E4%B9%9D%E9%BE%8D%E5%A1%98-%E8%A5%BF%E5%BC%8F-%E7%94%9C%E5%93%81-%E7%B3%96%E6%B0%B4-r892817"
                },
                {
                  "prompt": "what_to_order_first",
                  "text": "Start with the orange chocolate mousse tart (香橙朱古力慕斯撻).",
                  "source_url": "https://www.openrice.com/zh/hongkong/r-arte-by-padaria-%E4%B9%9D%E9%BE%8D%E5%A1%98-%E8%A5%BF%E5%BC%8F-%E7%94%9C%E5%93%81-%E7%B3%96%E6%B0%B4-r892817"
                },
                {
                  "prompt": "value_for_money",
                  "text": "The price per person ($201-400) is considered reasonable for the high-quality ingredients and unique creativity.",
                  "source_url": "https://www.weekendhk.com/restaurant/artebypadaria-%E5%B0%96%E6%B2%99%E5%92%80-2749466"
                },
                {
                  "prompt": "known_for",
                  "text": "The brand blends traditional French pastry with innovative elements and went viral in Hong Kong dessert circles within its first year.",
                  "source_url": "https://www.instagram.com/reel/DJbRs4Ks_nE"
                },
                {
                  "prompt": "how_old",
                  "text": "The chain had been open for less than a year as of September 2025.",
                  "source_url": "https://www.instagram.com/reel/DJbRs4Ks_nE"
                }
              ],
              "price_level": null,
              "lat": 22.33749,
              "lon": 114.17409
            },
            {
              "id": "01a0f27d-8371-70e4-a9ef-2c9593bfc555",
              "name": "Café & Meal MUJI",
              "category": "Café",
              "address": "LG1/F, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "known_for",
                  "text": "It's known for natural, healthy Japanese set meals with original flavors.",
                  "source_url": "https://hk.trip.com/moments/detail/hong-kong-38-15902707"
                },
                {
                  "prompt": "room_vibe",
                  "text": "Light music plays, making the atmosphere relaxed and enjoyable.",
                  "source_url": "https://hk.trip.com/moments/detail/hong-kong-38-15902707"
                },
                {
                  "prompt": "getting_there",
                  "text": "Take Exit C from Kowloon Tong MTR station.",
                  "source_url": "https://hk.trip.com/moments/detail/hong-kong-38-15902707"
                },
                {
                  "prompt": "best_dish",
                  "text": "The tomato red miso braised beef with bread is excellent.",
                  "source_url": "https://hk.trip.com/moments/detail/hong-kong-38-15902707"
                },
                {
                  "prompt": "what_to_order_first",
                  "text": "Order the 5-item set (五品料理) to try a variety of cold and hot dishes.",
                  "source_url": "https://hk.trip.com/moments/detail/hong-kong-38-15902707"
                }
              ],
              "price_level": null,
              "lat": 22.3374636999896,
              "lon": 114.173954011518
            },
            {
              "id": "01a0f27d-8371-71b8-99f6-539ce9160d0e",
              "name": "On-Yasai",
              "category": "Shabu-Shabu Restaurant",
              "address": "Shop LG1-29, Festival Walk",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "known_for",
                  "text": "The restaurant is known for its Japanese golden corn soup (日本金黃玉米湯), a seasonal soup base that sold out and returned due to demand.",
                  "source_url": "https://hkppltravel.com/245597/%E9%A3%9F%E9%80%9A%E5%A4%A9/%E9%A6%99%E6%B8%AF/%E7%81%A3%E4%BB%B4%E5%8D%80/%E9%8A%85%E9%91%BC%E7%81%A3/%E4%B8%8A%E5%B9%B4%E4%B8%80%E4%BD%8D%E9%9B%A3%E6%B1%82%E8%B3%A3%E6%96%B7%E7%A5%9E%E6%B9%AF%E5%9B%9E%E6%AD%B8%E6%B8%A9%E9%87%8E%E8%8F%9C%E9%BB%83%E9%87%91%E7%B2%9F%E7%B1%B3%E6%BF%83%E6%B9%AF%E6%B9%AF%E5%BA%95%E5%BC%B7%E5%8B%A2%E5%9B%9E%E6%AD%B8%E4%BB%8A%E5%B9%B4%E5%8A%A0%E6%8E%A8%E5%A5%B6%E8%93%8B%E7%8E%89%E7%B1%B3%E5%85%AC%E4%BB%B4"
                },
                {
                  "prompt": "need_to_book",
                  "text": "Booking via the KABU PASS App is recommended, especially for seasonal soups like the golden corn soup.",
                  "source_url": "https://www.instagram.com/p/DOQiHtlCATj"
                },
                {
                  "prompt": "drinks",
                  "text": "Set meals include a designated non-alcoholic drink.",
                  "source_url": "http://www.fooddiscuss.com/2015/12/on-yasai.html"
                },
                {
                  "prompt": "what_to_order_first",
                  "text": "The late market set meals (A to C) include rice or udon, half portion bamboo tube steamed chicken, dessert and a drink.",
                  "source_url": "http://www.fooddiscuss.com/2015/12/on-yasai.html"
                },
                {
                  "prompt": "best_dish",
                  "text": "Kuroge wagyu is offered as a premium ingredient.",
                  "source_url": "https://www.discoverhongkong.com/eng/travel-guide/qts/restaurants-results/restaurants-details.id76693.on-yasai.html"
                }
              ],
              "price_level": null,
              "lat": 22.337526,
              "lon": 114.17389
            },
            {
              "id": "01a0f27d-8371-7449-8a0f-e57da642c87f",
              "name": "Moon Palace 望月樓",
              "category": "Cantonese Restaurant",
              "address": "Shop 25, G/F, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "The Moon Palace braised pork rice (望月焗豬扒飯) is a signature dish.",
                  "source_url": "https://www.openrice.com/zh/hongkong/r-%E6%9C%9B%E6%9C%88%E6%A8%93-%E4%B9%9D%E9%BE%8D%E5%A1%98-%E5%B7%9D%E8%8F%9C-%E5%9B%9B%E5%B7%9D-r682119"
                },
                {
                  "prompt": "what_to_order_first",
                  "text": "Start with the garlic pork (蒜泥白肉), the first main dish listed.",
                  "source_url": "https://www.openrice.com/zh/hongkong/r-%E6%9C%9B%E6%9C%88%E6%A8%93-%E4%B9%9D%E9%BE%8D%E5%A1%98-%E5%B7%9D%E8%8F%9C-%E5%9B%9B%E5%B7%9D-r682119"
                },
                {
                  "prompt": "known_for",
                  "text": "Known for high-end Cantonese cuisine with luxury ingredients like abalone, sea cucumber, and shark fin, plus dim sum from a Michelin-recommended chef.",
                  "source_url": "https://lubuds.com/zh/moon-palace"
                },
                {
                  "prompt": "value_for_money",
                  "text": "The two-person set meal at $788 with fish and shrimp is considered quite worth it.",
                  "source_url": "https://maps.apple.com/place?auid=530490892667433692&lsp=9902"
                },
                {
                  "prompt": "room_vibe",
                  "text": "Family-friendly atmosphere in a convenient mall location above the MTR station.",
                  "source_url": "https://www.facebook.com/MoonPalaceFW/mentions"
                }
              ],
              "price_level": null,
              "lat": 22.337564,
              "lon": 114.17392
            },
            {
              "id": "01a0f27d-8371-74f4-8848-0061b9818697",
              "name": "丼吉日本吉列專門店餐廳",
              "category": "Japanese Restaurant",
              "address": "UG-19, UG/F, Festival Walk, 80 Tat Chee Ave",
              "area": "Sham Shui Po",
              "answers": [
                {
                  "prompt": "best_dish",
                  "text": "The tonkatsu pork chop 「吉列豬扒」 is the signature dish.",
                  "source_url": "https://www.ulifestyle.com.hk/community/detailpost/12e02310-41a4-42a5-b692-a3202b60a541/%E9%A6%99%E6%B8%AF%E6%94%BB%E7%95%A5/%E5%90%89%E5%88%97%E8%B1%AC%E6%89%92%E6%8E%A7%E5%BF%85%E7%9D%87%E4%B8%BC%E5%90%89%E4%BA%8C/cindyho/128466"
                },
                {
                  "prompt": "order_this_if_its_your_second_time",
                  "text": "Try the kurobuta pork fillet tonkatsu 「黑豚豬柳」 on your next visit.",
                  "source_url": "https://hk.trip.com/moments/theme/poi-tonkichi-tonkatsu-seafood-11741111-restaurant-993134"
                },
                {
                  "prompt": "known_for",
                  "text": "Food critic Chua Lam calls it Hong Kong's best tonkatsu specialist, with AAA rating and 5-time OpenRice winner.",
                  "source_url": "https://tonkichi.com.hk"
                },
                {
                  "prompt": "how_old",
                  "text": "The first branch opened in 1995 at Causeway Bay World Trade Centre, over 30 years ago.",
                  "source_url": "https://tonkichi.com.hk"
                },
                {
                  "prompt": "service",
                  "text": "It holds the Hong Kong Q Mark quality service certification.",
                  "source_url": "https://tonkichi.com.hk"
                }
              ],
              "price_level": null,
              "lat": 22.337589,
              "lon": 114.173932
            }
          ]
        }
        """#
#endif
