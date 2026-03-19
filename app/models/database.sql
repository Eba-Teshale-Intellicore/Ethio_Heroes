-- ==============================
-- USERS TABLE
-- ==============================

CREATE TABLE IF NOT EXISTS Users(
    id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    email_address TEXT UNIQUE NOT NULL,
    country TEXT,
    phone_number TEXT,
    password TEXT,
    login_type TEXT DEFAULT 'local',
    avatar TEXT DEFAULT 'default_avatar.png',
    bio TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- ERAS
-- ==============================

CREATE TABLE IF NOT EXISTS Eras(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    UNIQUE(name)
);

-- ==============================
-- CATEGORIES
-- ==============================

CREATE TABLE IF NOT EXISTS Categories(
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT
);

-- ==============================
-- HEROES
-- ==============================

CREATE TABLE IF NOT EXISTS Heroes(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    birth_year INTEGER,
    death_year INTEGER CHECK(death_year IS NULL OR death_year >= birth_year),
    era_id INTEGER REFERENCES Eras(id),
    short_description TEXT,
    full_biography TEXT,
    full_history TEXT,
    nationality TEXT DEFAULT 'Ethiopian',
    hero_image TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, birth_year)
);
-- ==============================
-- HERO CATEGORIES (M-M)
-- ==============================

CREATE TABLE IF NOT EXISTS HeroCategories(
    hero_id INTEGER REFERENCES Heroes(id),
    category_id INTEGER REFERENCES Categories(id),
    PRIMARY KEY(hero_id, category_id)
);

-- ==============================
-- HERO IMAGES
-- ==============================
CREATE TABLE IF NOT EXISTS HeroImages(
    id SERIAL PRIMARY KEY,
    hero_id INTEGER NOT NULL REFERENCES Heroes(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    caption TEXT,
    UNIQUE(hero_id, image_url)
);
-- ==============================
-- ACHIEVEMENTS
-- ==============================

CREATE TABLE IF NOT EXISTS Achievements(
    id SERIAL PRIMARY KEY,
    hero_id INTEGER REFERENCES Heroes(id),
    title TEXT,
    description TEXT,
    year INTEGER
);
-- ==============================
-- SOURCES
-- ==============================

CREATE TABLE IF NOT EXISTS Sources(
    id SERIAL PRIMARY KEY,
    hero_id INTEGER REFERENCES Heroes(id),
    source_title TEXT,
    source_link TEXT,
    UNIQUE (hero_id, source_title)
);

-- ==============================
-- FAVORITES
-- ==============================

CREATE TABLE IF NOT EXISTS Favorites(
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(id),
    hero_id INTEGER REFERENCES Heroes(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- ==============================
-- HERO VIEWS
-- ==============================

CREATE TABLE IF NOT EXISTS HeroViews(
    id SERIAL PRIMARY KEY,
    hero_id INTEGER REFERENCES Heroes(id),
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- COMMENTS
-- ==============================

CREATE TABLE IF NOT EXISTS Comments(
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(id),
    hero_id INTEGER REFERENCES Heroes(id),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- -- INSERT SOME TESTING 

INSERT INTO Eras (name, description) VALUES
('Ancient', 'Heroes and rulers from early Ethiopian history and ancient civilizations.'),
('Medieval', 'Leaders, emperors, and influential figures from the medieval period.'),
('Modern', 'Contemporary figures, athletes, scientists, and modern reformers.')
ON CONFLICT(name) DO NOTHING;

INSERT INTO Categories (id, name, description) VALUES
(1,'Athlete','Sports champions'),
(2,'Scientist','Scientific innovators'),
(3,'Doctor','Medical professionals'),
(4,'Leader','Political or national leaders'),
(5,'Artist','Creative figures'),
(6,'Activist','Human rights and social reformers'),
(7,'Engineer','Technology and engineering pioneers'),
(8,'Freedom Fighter','Resistance and independence heroes'),
(9,'Educator','Teachers and intellectual leaders'),
(10,'Inventor','Innovators and creators')
ON CONFLICT (id) DO NOTHING;



INSERT INTO Heroes
(name, birth_year, death_year, era_id, short_description, full_biography, full_history, hero_image)
VALUES

(
'Abebe Bikila',
1932,
1973,
3,
'Olympic marathon champion',
'First African Olympic gold medalist who won the 1960 marathon barefoot and defended the title in 1964.',
'Abebe Bikila was born in 1932 in the village of Jato in Ethiopia. Growing up in the Ethiopian highlands, he developed remarkable endurance by running long distances to school and helping with daily tasks. His childhood environment naturally trained his body for long-distance running.

Bikila''s formal introduction to athletics came when he joined the Imperial Bodyguard. There he received structured training and quickly gained attention for his speed, discipline, and endurance.

His historic breakthrough occurred at the 1960 Rome Olympics where he won the marathon running barefoot. This victory made him the first Ethiopian and the first African athlete to win an Olympic gold medal.

He later defended his title at the 1964 Tokyo Olympics, becoming one of the greatest marathon runners in history.

After a tragic car accident in 1969 left him paralyzed, Bikila still remained a symbol of determination and resilience.

His legacy inspired generations of Ethiopian runners and helped establish Ethiopia as a global powerhouse in long-distance running.',
'images/heroes/abebe_bikila.jpg'
),

('Tirunesh Dibaba', 1985, NULL, 3, 'Olympic distance runner',
'Multiple Olympic and World Champion long-distance runner known as the "Baby Faced Destroyer".',
'Tirunesh Dibaba was born in 1985 in the small town of Bekoji, Ethiopia, a region renowned for producing world-class distance runners. Growing up in the Ethiopian highlands, Dibaba was exposed to long-distance running at a young age, navigating hilly terrain and high-altitude environments that naturally built endurance and stamina. Her family encouraged athletic activity, and her siblings, including Ejegayehu Dibaba, were also accomplished runners, creating a supportive and competitive atmosphere that nurtured her talent.

Dibaba''s formal introduction to competitive running came during her teenage years, when she began participating in local and national events. Coaches quickly recognized her potential, noting her remarkable finishing kick, tactical intelligence, and capacity to sustain a relentless pace over long distances.

Tirunesh Dibaba''s international breakthrough occurred in the early 2000s, as she dominated both the 5000m and 10000m events in major championships. She showcased exceptional tactical intelligence, often controlling the pace of races and unleashing devastating finishing sprints that left competitors behind.

Her Olympic career solidified her status as one of the greatest long-distance runners in history. At the 2004 Athens Olympics, she won gold in the 5000m. At the 2008 Beijing Olympics, she captured gold in both the 5000m and 10000m events.

Tirunesh Dibaba''s legacy extends far beyond her medal count and world records. She has inspired countless young athletes in Ethiopia and around the globe to pursue distance running with discipline and resilience.',
'images/heroes/tirunesh_dibaba.jpg'),

('Derartu Tulu', 1972, NULL, 3, 'Olympic champion',
'First Black African woman to win Olympic gold in the 10,000m in 1992.',
'Derartu Tulu was born in 1972 in the town of Bekoji, Ethiopia, a region renowned for producing some of the world''s most elite distance runners. Growing up in the Ethiopian highlands, she was immersed in a culture that valued endurance, discipline, and athletic excellence. Her early years were spent navigating steep terrain and high-altitude landscapes, which naturally strengthened her cardiovascular endurance and mental resilience. Tulu''s family provided both emotional and practical support for her early endeavors, and she displayed remarkable determination and athletic talent from a young age. These formative experiences instilled in her the perseverance and focus that would later become hallmarks of her competitive career.

Tulu''s formal introduction to competitive athletics began during her teenage years, when she participated in local and regional races. Coaches quickly recognized her exceptional ability to sustain a strong pace over long distances, combined with tactical intelligence that set her apart from her peers. Training in structured programs that emphasized both endurance and strategy, she developed an understanding of pacing, race tactics, and the psychological aspects of competition.

The pinnacle of Tulu''s early career came at the 1992 Barcelona Olympics, where she made history by becoming the first Black African woman to win Olympic gold in the 10,000 meters. Her victory symbolized hope, empowerment, and representation for women across Africa and inspired countless young women to pursue athletics.

Following her historic Olympic victory, Tulu continued to compete at the highest levels, earning medals in subsequent World Championships and at the 2000 Sydney Olympics. Her career during this period was marked by meticulous training, high-altitude conditioning, and strategic preparation.

Derartu Tulu''s legacy transcends her personal victories. She inspired generations of African women to pursue athletics, breaking barriers of gender, geography, and opportunity. Through mentorship and community engagement, she has helped nurture future Ethiopian champions.',
'images/heroes/derartu_tulu.jpg'),

('Haile Selassie', 1892, 1975, 3, 'Emperor of Ethiopia',
'Modernized Ethiopia and helped establish the Organization of African Unity.',
'Haile Selassie I was born in 1892 in the small town of Ejersa Goro, in the Harar province of Ethiopia, into the Solomonic dynasty, a lineage that claimed descent from King Solomon and the Queen of Sheba. His birth name was Lij Tafari Makonnen, and from a young age he was groomed for leadership, receiving a traditional education in religion, history, and governance. Growing up in a period of regional upheaval and imperial consolidation, he quickly learned the complex dynamics of Ethiopian politics, balancing the interests of provincial nobles, the church, and the monarchy. His upbringing emphasized discipline, education, and a sense of duty, which shaped his vision for Ethiopia''s future and his approach to leadership throughout his reign.

Selassie''s early career involved extensive involvement in governance and military matters under Emperor Menelik II and later Emperor Zewditu. Appointed governor of Harar province at a young age, he implemented reforms to modernize local administration, improve taxation, and foster development in infrastructure, education, and health services. These reforms reflected his belief in modernization as essential to national strength. By the 1920s, he emerged as a national figure and de facto heir apparent, leading campaigns to centralize authority, mediate conflicts among regional warlords, and strengthen the central government. His experience in administration and diplomacy prepared him for his eventual coronation in 1930 as Emperor Haile Selassie I, with a vision to transform Ethiopia into a modern state while preserving its sovereignty and cultural heritage.

One of the most defining chapters of Haile Selassie''s reign was the Italian invasion of Ethiopia in 1935. Despite facing a militarily superior Italian army armed with modern weaponry, Selassie led resistance efforts, inspiring Ethiopian forces with his courage and strategic insight. During this period, he addressed the League of Nations in Geneva, appealing to the international community for assistance and highlighting the dangers of fascist aggression. His speech became an enduring symbol of international justice and moral authority, even though material support from other nations was limited. Forced into exile in England, he continued diplomatic efforts to rally support for Ethiopia''s liberation, maintaining the legitimacy of his monarchy while building networks that would eventually facilitate his return to power in 1941 after the defeat of Italian forces in East Africa.

Following his restoration to the throne, Haile Selassie embarked on a comprehensive program of modernization, reform, and nation-building. He introduced Ethiopia''s first written constitution in 1931 and revised it in 1955 to expand civil rights and political participation, though centralized power remained in his hands. Investments in infrastructure, including roads, schools, hospitals, and communication systems, transformed urban and rural Ethiopia. He also emphasized education and modernization of the military. On the international stage, he became a leading advocate for Pan-Africanism, playing a pivotal role in the formation of the Organization of African Unity (OAU) in 1963, promoting African solidarity, independence, and cooperation among newly independent states. His diplomatic vision elevated Ethiopia''s status globally and inspired movements for African unity and self-determination.

In his later years, Haile Selassie faced political challenges, including growing domestic opposition due to economic inequality, drought, and famine crises in the 1970s. These pressures culminated in his overthrow in 1974 by a military junta, ending a reign of over four decades. Despite political turmoil, his legacy endured through the modernization of Ethiopia, the establishment of international and regional institutions, and his influence as a symbol of African pride and Pan-African ideals. His life and leadership continue to inspire Ethiopians and global leaders alike, reflecting a commitment to sovereignty, social development, and moral authority. Haile Selassie remains an iconic figure in African history, remembered as a reformist monarch who navigated the challenges of modernization, colonial threats, and the quest for African unity.',
'images/heroes/haile_selassie.jpg'),

('Tewodros II', 1818, 1868, 2, 'Emperor and reformer',
'Worked to unify Ethiopia and modernize military and administration.',
'Tewodros II was born in 1818 in the region of Qwara, Ethiopia, into a period marked by political fragmentation and feudal strife. His early life was shaped by a combination of noble lineage and local conflict, exposing him to the challenges of governance and military strategy from a young age. Orphaned early, he was raised amidst turmoil and learned both the skills of leadership and the complexities of Ethiopian feudal politics. These formative experiences instilled in him a profound understanding of loyalty, discipline, and the strategic use of power. From childhood, he displayed courage, intelligence, and a determination to restore unity to a divided nation, traits that would define his reign.

As he grew into adulthood, Tewodros II began consolidating power in northern and central Ethiopia, gradually uniting fragmented provinces under his authority. He engaged in careful diplomacy with local rulers while simultaneously demonstrating military prowess, often leading campaigns personally to subdue resistance. Through strategic alliances, sieges, and decisive battles, he brought stability to regions long plagued by conflict. His reforms included centralizing authority, standardizing tax collection, and reorganizing provincial administration to create a coherent state structure. These efforts faced persistent challenges from feudal lords accustomed to autonomy, requiring both political acumen and decisive action to enforce his vision of a unified Ethiopia.

A cornerstone of Tewodros II''s legacy was his determination to modernize the Ethiopian military and administrative systems. Recognizing that a strong centralized army was essential for unification, he trained troops in modern tactics, acquired firearms, and reorganized the command structure. He implemented new taxation policies to fund these military improvements and invested in infrastructure to improve communication and governance. His emphasis on discipline, merit-based promotions, and standardized training transformed Ethiopia''s military capabilities. These reforms were ambitious, confronting centuries of decentralized authority and traditional practices, but they laid the foundation for a modern state capable of defending its sovereignty and asserting authority across its territories.

Tewodros II''s reign was marked by both domestic and international challenges. Internally, he faced rebellions from nobles resisting centralization, as well as the difficulty of uniting diverse regions with distinct local traditions. Externally, he navigated tense relations with the expanding British Empire, culminating in the 1868 confrontation known as the British expedition to Ethiopia. Despite limited technological and logistical resources, he displayed strategic courage and personal bravery during these conflicts. The siege at Magdala and his eventual death there reflected both the formidable resistance he faced and the enduring determination that characterized his rule.

Tewodros II''s enduring legacy lies in his vision for a unified and modern Ethiopia. Although his reign ended tragically, he inspired successive leaders to continue efforts toward centralization, modernization, and national unity. His reforms in military organization, taxation, and administration provided a blueprint for a more cohesive state structure, while his courage in confronting both internal and external threats cemented his status as a symbol of Ethiopian sovereignty. Generations of Ethiopians remember Tewodros II as a visionary reformer and foundational leader whose ambition helped lay the groundwork for a modern Ethiopian nation-state.',
'images/heroes/tewodros_ii.jpg'),

('Belay Zeleke', 1912, 1945, 3, 'Resistance leader',
'Led Ethiopian patriots during the Italian occupation.',
'Belay Zeleke was born in 1912 in the northern Ethiopian province of Gojjam, in a period marked by political complexity and regional challenges. From an early age, he displayed remarkable courage, resourcefulness, and a keen awareness of the social and political dynamics around him. Growing up amidst the rich cultural and historical traditions of Gojjam, he absorbed stories of valor and resistance against foreign encroachment, which deeply influenced his sense of duty and patriotism. His family, community, and local leaders instilled in him the values of discipline, loyalty, and collective responsibility, which later shaped his leadership style. These formative experiences equipped Belay Zeleke with both the strategic insight and moral resolve required to confront a foreign invader and defend Ethiopia''s sovereignty.

During the Italian invasion of Ethiopia in 1936, Belay Zeleke emerged as a natural leader of the resistance movement. Witnessing the occupation of Ethiopian territories, he mobilized local youth and elders to resist the Italian forces using guerrilla warfare tactics adapted to the rugged terrain of the northern highlands. He emphasized mobility, intelligence gathering, and surprise attacks, often exploiting intimate knowledge of the land to outmaneuver enemy troops. His charisma and strategic insight attracted many followers, and his forces became a central pillar of the patriotic resistance. Belay Zeleke''s leadership was distinguished by a combination of personal bravery, tactical innovation, and the ability to inspire loyalty among diverse groups of fighters.

Belay Zeleke led numerous campaigns that became legendary in Ethiopian military history. His guerrilla operations targeted supply lines, Italian garrisons, and communication networks, severely disrupting the occupiers'' control. He coordinated raids, ambushes, and night attacks, often combining small, agile units to maximize impact while minimizing casualties. These operations demonstrated his deep understanding of asymmetric warfare and the advantages of local terrain knowledge. His military leadership was not only tactical but also moral, emphasizing protection of civilians, respect for local communities, and the maintenance of morale under extremely difficult conditions.

Beyond his military accomplishments, Belay Zeleke was instrumental in organizing communities to support the resistance. He coordinated logistics, secured food and medical supplies, and facilitated communication between disparate groups of patriots. His approach combined practical governance with military leadership, ensuring that liberated territories maintained stability and order. He built trust among local populations, fostering a sense of collective responsibility and national unity.

Belay Zeleke''s legacy endures as a symbol of patriotism, resilience, and the struggle for Ethiopian sovereignty. Despite his untimely death in 1945, his story continues to inspire generations, reminding Ethiopians of the power of courage, unity, and determination in the face of oppression. His leadership exemplifies the integration of tactical skill, moral authority, and community mobilization, establishing a model for national resistance movements.',
'images/heroes/belay_zeleke.jpg'),


('Afework Tekle', 1932, 2012, 3, 'Famous painter',
'Internationally recognized Ethiopian artist known for monumental works.',
'Afework Tekle was born in 1932 in the culturally rich region of Gondar, Ethiopia. From an early age, he showed a remarkable affinity for drawing and painting, spending hours studying local church murals, traditional Ethiopian iconography, and the natural landscapes surrounding his home. His family and local mentors recognized his talent and encouraged him to pursue formal training. Growing up during a time of social and political change, Tekle absorbed influences from both traditional Ethiopian art and emerging modern artistic movements, developing a profound understanding of the cultural and spiritual significance of visual expression. These formative years laid the foundation for a lifelong commitment to creating art that bridged heritage and contemporary innovation.

Tekle''s artistic development accelerated as he enrolled in formal art education programs and apprenticed under prominent Ethiopian painters and sculptors. He experimented with various media, including oils, acrylics, and sculpture, and refined techniques that allowed him to blend traditional Ethiopian motifs with modern artistic sensibilities. Early exhibitions of his work demonstrated his ability to evoke powerful emotional and spiritual narratives while maintaining a distinctive style. Through his dedication, he became a leading figure in Ethiopian visual arts, known for meticulous attention to detail, expressive compositions, and the ability to tell complex stories through imagery.

Afework Tekle gained international recognition through monumental murals, large-scale paintings, and sculptural installations. His works were commissioned for public spaces, museums, and cultural institutions, both in Ethiopia and abroad. Notable projects included murals depicting historical events, spiritual traditions, and social themes central to Ethiopian society. His exhibitions in Europe, North America, and Africa introduced audiences worldwide to the richness of Ethiopian art, fostering cross-cultural dialogue and appreciation.

A hallmark of Tekle''s oeuvre was the fusion of Ethiopian traditional imagery with modern techniques, reflecting both a respect for heritage and a forward-looking creative vision. His works frequently explored themes of spirituality, community, history, and social justice, employing symbolism drawn from Ethiopian Orthodox iconography, folklore, and cultural rituals. Tekle experimented with perspective, texture, and layering to create immersive artistic experiences.

Afework Tekle''s enduring legacy lies in his influence on generations of Ethiopian artists and the international art community. He mentored young artists and promoted the importance of cultural heritage within modern creative expression. His contributions elevated Ethiopian art on the global stage and demonstrated the power of art as a medium for cultural preservation, dialogue, and inspiration.',
'images/heroes/afework_tekle.jpg'),

('Melaku Worede', 1928, 2020, 3, 'Agricultural scientist',
 'Preserved thousands of crop varieties and promoted seed biodiversity.',
 'Melaku Worede was born in 1928 in Ethiopia, during a period of significant social and political change, and from an early age, he developed a deep appreciation for the natural environment, agriculture, and the vital role that food security played in the lives of ordinary Ethiopians. Growing up in a rural setting, he observed the diversity of indigenous crops and traditional farming practices, which cultivated his lifelong passion for preserving plant genetic resources. He pursued formal education in agriculture, excelling in both theoretical studies and practical applications, and demonstrated a rare combination of scientific curiosity, analytical skill, and an unwavering commitment to improving the sustainability of Ethiopian agriculture. His early experiences instilled a profound understanding of the delicate balance between humans and their environment and shaped his vision for the future of food security and ecological farming in his homeland. Melaku Worede began his career by studying the challenges faced by farmers in maintaining crop diversity and resilience in the face of environmental stress, including droughts, soil erosion, and disease. Recognizing the risk that modernization and monoculture posed to traditional varieties, he advocated for the systematic collection, preservation, and documentation of indigenous seeds. Over decades, he built and managed Ethiopia''s seed banks, meticulously cataloging thousands of crop varieties, particularly cereals such as teff, wheat, barley, and sorghum, ensuring that the genetic diversity essential for food security would not be lost to future generations. His pioneering work in seed preservation was not limited to collection; he developed methods to maintain seed viability over long periods and adapted traditional knowledge to modern conservation techniques. Worede collaborated extensively with local farmers, emphasizing participatory approaches that respected indigenous agricultural wisdom and integrated it with scientific methods, thus creating a model for sustainable farming that empowered communities and preserved biodiversity. Through his advocacy, education, and training programs, he spread knowledge of seed conservation techniques and ecological farming practices across Ethiopia, encouraging farmers to embrace sustainable methods that increased resilience against environmental challenges such as drought, pests, and climate variability. Melaku Worede''s work attracted international attention, leading to collaborations with global agricultural organizations, research institutions, and development agencies. He served as an advisor to the Food and Agriculture Organization and other bodies, contributing his expertise to projects aimed at promoting biodiversity, combating hunger, and improving rural livelihoods worldwide. His research publications, lectures, and participatory workshops helped bridge the gap between local agricultural practices and international scientific standards, positioning Ethiopia as a leader in seed conservation and sustainable agriculture. Beyond the technical aspects of his work, Worede was a passionate advocate for policies that protected indigenous crop varieties and promoted food sovereignty, arguing that biodiversity was essential not only for ecological stability but also for cultural heritage, nutrition, and economic resilience. He emphasized the interconnectedness of ecosystems, communities, and economies, and his holistic vision influenced national agricultural policy and inspired similar programs across Africa and other regions. Over the course of his career, he received numerous awards and recognition for his contributions to agriculture, ecology, and sustainability, both domestically and internationally, yet he remained deeply committed to fieldwork, mentoring young scientists, and maintaining close ties with Ethiopian farmers. His impact extended far beyond Ethiopia; his approaches to participatory seed preservation and ecological farming became models for sustainable agriculture globally, influencing international discourse on food security, genetic resources, and climate resilience. Even in his later years, Worede continued to advise, teach, and inspire, ensuring that the next generation of agricultural scientists and farmers would carry forward his mission of preserving crop diversity, promoting sustainability, and safeguarding the ecological foundations of human life. Melaku Worede passed away in 2020, leaving behind an unparalleled legacy in agricultural science, a profound influence on Ethiopian society, and a model of environmentally conscious innovation that continues to resonate worldwide. His life stands as a testament to the power of combining scientific knowledge, traditional wisdom, and passionate advocacy to create lasting solutions for food security, biodiversity preservation, and sustainable development. His contributions remain embedded in Ethiopia''s agricultural institutions, international research initiatives, and the practices of countless farmers who continue to benefit from his vision and dedication to the protection and enhancement of crop diversity.',
 'images/heroes/melaku_worede.jpg'),

('Kitaw Ejigu', 1948, 2006, 3, 'Aerospace engineer',
'First Ethiopian aerospace scientist working on NASA-related technologies.',
'Kitaw Ejigu was born in 1948 in Ethiopia, a country rich in culture but with limited access to advanced scientific education at the time. From a young age, he displayed exceptional aptitude for mathematics, physics, and engineering, fueled by curiosity about space, flight, and the universe beyond the Earth. His formative years included extensive self-study, participation in local science competitions, and mentorship from teachers who recognized his exceptional talent. Ejigu''s early fascination with rocketry, aerodynamics, and satellite systems inspired him to pursue higher education in the sciences, a path that would eventually take him far beyond the borders of Ethiopia. He graduated from national institutions with top honors, quickly earning recognition for his analytical skills, problem-solving abilities, and innovative thinking. His dedication to learning and his visionary mindset prepared him to join the global scientific community, where he would become a pioneer for Ethiopian scientists in aerospace research. Over the course of his life, he navigated a series of complex scientific, cultural, and logistical challenges to become the first Ethiopian aerospace engineer contributing to NASA and other U.S. aerospace programs. His work included research and development in satellite technologies, propulsion systems, spacecraft design, orbital mechanics, and aerodynamics. Ejigu participated in multi-disciplinary projects, collaborating with top engineers, physicists, and scientists, producing research reports, patent applications, and experimental prototypes. He introduced innovative approaches to satellite communications, optimization of aerospace propulsion, and advanced design methodologies, which were implemented in both experimental and operational missions. Ejigu also worked on developing frameworks for integrating Ethiopian scientific talent into international projects, mentoring young engineers and inspiring students to pursue careers in STEM fields. Through his efforts, he became a bridge between Ethiopia and the global aerospace community, demonstrating that intellectual talent could thrive across continents and that Ethiopian scientists could make significant contributions to cutting-edge technologies. Ejigu''s career continued to expand as he assumed senior roles in NASA-affiliated research projects and aerospace consulting initiatives. His work in propulsion, satellite design, and aerospace engineering earned him international recognition and numerous awards, while also inspiring a generation of engineers and scientists from Africa and the diaspora. Beyond technical contributions, he advocated for STEM education, encouraging young Ethiopians to pursue careers in science, technology, engineering, and mathematics. Ejigu emphasized the importance of research, innovation, and critical thinking as the foundations for national development and global competitiveness. His achievements revolutionized Ethiopian participation in aerospace science. He demonstrated that vision, determination, and technical skill could place Ethiopia on the map of space exploration.',
'images/heroes/kitaw_ejigu.jpg'),

('Bogaletch Gebre', 1953, 2019, 3, 'Women rights activist',
 'Founded organizations combating harmful traditional practices.',
 'Bogaletch Gebre was born in 1953 in a rural Ethiopian community, where traditional social practices and deeply rooted gender norms shaped daily life. From an early age, she observed the challenges faced by girls and women in her community, including restrictions on education, early marriage, and practices such as female genital mutilation. Motivated by a sense of justice and compassion, she pursued education relentlessly, overcoming obstacles related to social expectations, limited local schooling, and cultural resistance. Her early exposure to the hardships endured by women inspired her lifelong commitment to social activism and gender equality. Bogaletch pursued formal education in Ethiopia, where she excelled academically and developed critical awareness of the intersection between culture, law, and human rights. She became increasingly involved in community initiatives aimed at empowering girls, addressing social injustices, and advocating for education as a transformative tool. These early experiences provided the foundation for her understanding of grassroots organization, community mobilization, and the necessity of culturally sensitive approaches to social reform. In addition to her formal studies, she gained experience by working with local organizations that promoted health, education, and women''s rights, which strengthened her skills in program management, negotiation, and advocacy. Recognizing the urgent need to address harmful traditional practices, she founded KMG Ethiopia, an organization dedicated to eliminating female genital mutilation, early and forced marriage, and other practices that limited women''s autonomy. Through KMG, she implemented community-based programs that combined education, awareness campaigns, and advocacy, effectively creating dialogue within communities that had long resisted change. Her approach emphasized respect for cultural identity while promoting human rights, demonstrating that social reform could be achieved through engagement, education, and empowerment rather than confrontation. Over the years, Bogaletch led numerous campaigns to reach rural and urban communities, training local leaders, health workers, and volunteers to act as agents of change. She organized workshops, seminars, and discussion forums that educated families about the health risks and human rights violations associated with harmful traditional practices. These programs were designed to build trust, reduce resistance, and promote gradual adoption of new social norms, showing that sustainable change requires a long-term commitment to both education and cultural understanding. Her work extended beyond advocacy; she also conducted research to document the prevalence and effects of harmful practices, providing evidence that informed both national policy and international discourse. These studies highlighted the social, psychological, and health consequences faced by women, influencing government agencies, NGOs, and international organizations to adopt supportive policies and programs. Bogaletch Gebre’s efforts gained recognition for their measurable impact: communities that adopted her programs reported significant reductions in female genital mutilation and early marriage, increased school attendance among girls, and greater participation of women in community leadership. She became a mentor for young activists, providing guidance, resources, and encouragement to ensure that the next generation would continue the struggle for gender equality. Internationally, her work attracted acclaim, leading to collaborations with organizations such as the United Nations, international NGOs, and human rights advocacy groups. She participated in conferences, published research, and gave talks that showcased Ethiopia as a model for culturally sensitive social reform, demonstrating that grassroots engagement can yield meaningful, sustainable change. Beyond the measurable outcomes, Bogaletch’s leadership created a shift in societal attitudes, empowering women to assert their rights, participate in decision-making, and pursue education and professional opportunities previously denied to them. Her approach combined moral courage, strategic thinking, and the ability to mobilize communities, proving that effective activism requires both vision and practical implementation. Even in regions resistant to change, her programs facilitated dialogue that allowed men, women, elders, and youth to collectively examine traditional practices, consider alternatives, and adopt healthier, more equitable norms. Bogaletch Gebre’s legacy extends beyond Ethiopia; her work inspired activists across Africa to challenge harmful traditional practices while respecting cultural contexts. Through mentorship, training, and international engagement, she created a network of women''s rights advocates who continue to implement programs modeled on her approach. Her vision of an empowered, educated, and autonomous female population remains a guiding principle for social reform initiatives continent-wide. She received numerous awards and accolades for her pioneering work, reflecting both national and international recognition of her contributions. Despite these honors, she remained grounded in her commitment to the communities she served, consistently returning to rural areas, engaging with local leaders, and monitoring the impact of her programs. Bogaletch Gebre passed away in 2019, leaving behind a profound legacy of activism, social change, and empowerment. Her life demonstrates the transformative power of education, advocacy, and culturally informed engagement. Today, the systems, organizations, and networks she established continue to combat harmful traditional practices, expand educational access, and promote gender equality. Her story serves as a model for activists worldwide, illustrating that meaningful social change arises from perseverance, empathy, and strategic leadership in the service of human rights.',
 'images/heroes/bogaletch_gebre.jpg'),


('Aklilu Lemma', 1934, 1997, 3, 'Medical scientist',
 'Discovered plant-based treatment for schistosomiasis disease.',
 'Aklilu Lemma was born in 1934 in Ethiopia, during a period when scientific education and research infrastructure were limited, yet he displayed extraordinary curiosity and intellectual capability from a young age. Growing up, he observed the health challenges faced by rural communities, particularly parasitic diseases such as schistosomiasis (bilharzia), which affected thousands of people and posed a significant threat to agricultural productivity and community well-being. Lemma pursued formal education in biology and medical sciences, excelling in studies related to parasitology, microbiology, and epidemiology. Early experiences working in rural clinics and observing the impact of endemic diseases inspired him to dedicate his life to research aimed at improving public health in Ethiopia and beyond. His education, combined with field exposure, instilled in him a unique combination of theoretical knowledge and practical understanding, enabling him to approach health challenges with both scientific rigor and community sensitivity. 

During his career, Lemma discovered that the berries of the Endod plant (Phytolacca dodecandra) could be used as an effective, low-cost, and environmentally sustainable molluscicide to control the snail vectors responsible for spreading schistosomiasis. His research combined laboratory experiments, field trials, and collaborations with local farmers, ensuring that the solution was not only scientifically valid but also socially and economically feasible. Lemma meticulously documented his findings, analyzing the toxicity of Endod to snails, its impact on aquatic ecosystems, and the practicality of large-scale application. He conducted training sessions with local communities, demonstrating how to cultivate and deploy the plant to reduce disease prevalence while maintaining ecological balance. This discovery represented a breakthrough in tropical medicine, providing an affordable, plant-based solution for one of Africa''s most persistent parasitic diseases. 

Aklilu Lemma''s work had a profound effect on public health policy and practice in Ethiopia and neighboring countries. Government agencies and non-governmental organizations adopted Endod-based control strategies, dramatically reducing the incidence of schistosomiasis in affected areas. Lemma worked closely with international research institutions, presenting his findings at conferences and publishing studies in peer-reviewed journals. His efforts emphasized the integration of traditional knowledge, local resources, and modern scientific methodology, setting a precedent for sustainable, community-oriented medical interventions. He advocated for a holistic approach to disease control, combining environmental management, public education, and scientific research to maximize health outcomes. 

Lemma''s contributions were recognized globally, most notably with the **Right Livelihood Award**, often referred to as the "Alternative Nobel Prize," which highlighted his innovative and practical approach to solving public health challenges. Beyond the award, he influenced generations of scientists and public health professionals, mentoring students and fostering research programs that combined tropical medicine, community engagement, and sustainable interventions. His life exemplified the intersection of scientific excellence, practical application, and humanitarian concern, showing that locally relevant research could have global significance. 

Aklilu Lemma''s legacy continues to impact medical science, public health, and tropical disease control. The methodologies he developed for integrating plant-based solutions into disease prevention programs remain a model for sustainable, community-driven interventions. His discoveries continue to inspire researchers seeking innovative approaches to combating parasitic diseases, particularly in resource-limited settings. Lemma''s vision extended beyond immediate health outcomes; he demonstrated the power of combining rigorous science with social responsibility, creating lasting improvements in the lives of millions. His dedication, intellectual curiosity, and compassion have cemented his status as one of Ethiopia''s most influential medical scientists, whose work resonates across Africa and the global scientific community.',
 'images/heroes/aklilu_lemma.jpg'),


('Gebisa Ejeta', 1950, NULL, 3, 'Plant geneticist',
 'Developed drought-resistant sorghum varieties benefiting millions.',
 'Gebisa Ejeta was born in 1950 in a rural community in Ethiopia, where he grew up witnessing the challenges faced by farmers in semi-arid regions, particularly the frequent droughts and crop failures that threatened food security. From a young age, he developed an interest in plants, agriculture, and problem-solving, often observing local farmers and helping in the fields. These formative experiences shaped his understanding of the relationship between climate, soil, and crop productivity and fostered a lifelong commitment to improving agricultural resilience. Ejeta pursued formal education in Ethiopia, excelling in biology and agricultural sciences, and demonstrated remarkable aptitude for genetics, plant breeding, and agronomy. Recognizing the potential of scientific research to transform lives, he sought higher education opportunities abroad, ultimately earning advanced degrees that equipped him with the tools to address pressing challenges in food security and crop improvement.

Ejeta''s professional career focused on sorghum, a staple cereal critical for millions of people in Ethiopia and across Africa. He conducted rigorous research on sorghum genetics, aiming to develop varieties that were not only high-yielding but also resistant to drought, pests, and diseases. Through meticulous cross-breeding, field trials, and selection processes, Ejeta identified traits that enhanced resilience, grain quality, and productivity. His work integrated both classical plant breeding techniques and modern genetic insights, allowing for innovative solutions tailored to the environmental conditions of semi-arid regions. Field trials were conducted in collaboration with local farmers, agricultural extension services, and international research centers, ensuring that the new varieties were practical, adaptable, and sustainable. These programs involved extensive testing, monitoring, and feedback loops, creating a dynamic process that continually improved crop performance while directly engaging the communities who depended on sorghum for their livelihoods.

The impact of Ejeta''s work was profound. The drought-resistant sorghum varieties he developed significantly increased yields, reduced crop losses, and improved food security for millions of people in Ethiopia, sub-Saharan Africa, and other drought-prone regions. By enhancing agricultural resilience, his research reduced vulnerability to famine, promoted stable livelihoods, and contributed to the sustainability of smallholder farming systems. Beyond production gains, Ejeta''s sorghum varieties also provided better nutritional quality, supporting healthier diets and contributing to broader public health outcomes. His approach exemplified the integration of scientific research, local knowledge, and practical implementation, creating solutions that were not only effective but socially and economically appropriate.

Gebisa Ejeta''s contributions earned him international recognition, including the prestigious **World Food Prize**, acknowledging his transformative impact on global food security and agricultural innovation. His work positioned him as a leading authority in plant breeding and genetics, influencing research programs worldwide. He collaborated with universities, international agricultural research centers, governments, and non-governmental organizations, sharing expertise, mentoring young scientists, and promoting the application of science to solve pressing agricultural problems. Ejeta also contributed to policy development, advising on strategies for crop improvement, sustainable farming, and climate adaptation, demonstrating how scientific innovation can shape both practice and policy in agriculture.

Beyond his immediate research, Ejeta''s legacy includes fostering the next generation of plant geneticists and agricultural scientists. Through mentorship, training programs, and international collaborations, he empowered countless researchers to continue work in crop improvement, food security, and sustainable agriculture. His vision emphasized resilience, adaptation to environmental challenges, and the ethical responsibility of scientists to improve human well-being. Today, his drought-resistant sorghum varieties continue to benefit millions of farmers and consumers, ensuring that his work has lasting influence on global food systems. Ejeta''s career stands as a testament to the power of combining scientific knowledge, practical application, and community engagement to solve some of the most pressing challenges facing humanity, leaving a profound and enduring legacy in agriculture, genetics, and human development.',
 'images/heroes/gebisa_ejeta.jpg'),


('Mamo Wolde', 1932, 2002, 3, 'Olympic marathon winner',
 'Won Olympic gold medal in the 1968 marathon.',
 'Mamo Wolde was born in 1932 in a rural region of Ethiopia, where daily life involved physical endurance, farming, and walking long distances. These early experiences contributed to his natural stamina and resilience, foundational traits that would later define his career as a marathon runner. From a young age, Wolde displayed athletic talent, participating in local races, school competitions, and community events, where his speed, determination, and tactical awareness became apparent. Recognizing his potential, local coaches and mentors encouraged him to pursue athletics more seriously, guiding him through structured training routines and competitive opportunities. His early exposure to both the challenges of long-distance running and the discipline required to excel laid the groundwork for his future Olympic achievements.  

As Wolde advanced in his athletic career, he began participating in national competitions, where he consistently demonstrated exceptional endurance, strategic pacing, and mental fortitude. His training regimen was rigorous and carefully designed to optimize cardiovascular performance, muscle strength, and recovery, combining traditional Ethiopian endurance techniques with modern athletic methodologies introduced by experienced coaches. He mastered long-distance running strategies, including energy conservation, optimal hydration, and terrain adaptation, allowing him to excel in marathon events characterized by extreme physical and mental demands. These techniques, refined over years of disciplined practice, positioned him as one of Ethiopia''s leading athletes and prepared him for the international stage.

Mamo Wolde''s crowning achievement came at the 1968 Mexico City Olympics, where he won the marathon gold medal, cementing his place in athletic history and continuing the legacy of Ethiopian long-distance dominance initiated by Abebe Bikila. The high-altitude conditions of Mexico City posed a significant challenge, yet Wolde''s careful preparation, acclimatization, and race-day strategy allowed him to maintain a consistent pace and endurance throughout the 42.195 kilometers. His victory was celebrated nationally and internationally, symbolizing both personal achievement and Ethiopia''s growing prominence in global athletics. Wolde''s performance was not only a testament to his physical capabilities but also to his psychological resilience, strategic planning, and ability to remain focused under intense pressure.

Following his 1968 victory, Wolde continued to compete at the highest levels, participating in subsequent Olympic Games and international marathons. He consistently demonstrated excellence, adaptability, and leadership, inspiring fellow Ethiopian runners and athletes from around the world. His training methods, which emphasized both physical conditioning and mental preparedness, became a model for emerging runners seeking to compete on the global stage. Beyond his personal achievements, Wolde actively mentored younger athletes, sharing insights on endurance, pacing, and strategic racing, ensuring that Ethiopia''s legacy in long-distance running continued to thrive. His guidance emphasized discipline, resilience, and the importance of national pride in sporting endeavors.

Mamo Wolde''s legacy extends far beyond his Olympic medals. He transformed the perception of Ethiopian athletics, establishing the country as a powerhouse in long-distance running and inspiring generations of runners to pursue excellence in international competitions. His dedication, perseverance, and humility serve as a blueprint for aspiring athletes, highlighting the combination of talent, hard work, and mental toughness required to succeed at the highest levels. Wolde''s life story continues to be celebrated in Ethiopia and across the world, demonstrating how individual achievement can foster national pride, inspire future generations, and elevate the status of sports as a platform for cultural and international recognition. His enduring influence resonates in the continued dominance of Ethiopian distance runners on the global stage and the ongoing admiration for his athletic accomplishments.',
 'images/heroes/mamo_wolde.jpg'),


('Kenenisa Bekele', 1982, NULL, 3, 'Long distance runner',
 'World record holder in 5000m and 10000m track events.',
 'Kenenisa Bekele was born in 1982 in the small town of Bekoji, Ethiopia, a region renowned for producing world-class long-distance runners. Growing up at high altitude, he developed natural endurance and a love for running through daily life, including school commutes, chores, and recreational races with peers. Early coaches recognized his exceptional talent and encouraged him to participate in local and regional competitions, where he consistently outperformed older and more experienced runners. Bekele''s early exposure to competitive athletics, combined with rigorous physical activity inherent to his environment, laid the foundation for his future success on the world stage. His disciplined training, strategic mindset, and unwavering focus distinguished him from other young athletes, propelling him toward national and international recognition.

As a junior athlete, Bekele quickly established himself as a prodigy in long-distance events, winning numerous races at national championships and international junior competitions. His performances attracted the attention of national coaches, and he was selected for Ethiopia''s elite training programs, where he honed his technique, pacing strategies, and mental preparation. Bekele''s work ethic, combined with meticulous coaching, allowed him to develop the aerobic capacity, muscular endurance, and psychological resilience necessary to compete at the highest levels of track and field. His training emphasized periodization, high-altitude adaptation, interval sessions, and long-distance endurance runs, creating a foundation for sustained performance in both the 5000m and 10000m events. 

Bekele''s career achievements include multiple Olympic gold medals and World Championship titles in both the 5000m and 10000m. He set world records in these events, demonstrating a combination of raw speed, tactical intelligence, and unparalleled endurance. Each race was characterized by careful pacing, strategic surges, and a final sprint that often left competitors unable to respond. His ability to maintain a high tempo over extreme distances, read competitors, and adapt to race conditions made him one of the most dominant long-distance runners in history. Bekele''s performances were not only victories for him personally but also a continuation of Ethiopia''s legacy in distance running, building on the accomplishments of legendary predecessors like Abebe Bikila and Haile Gebrselassie. 

Beyond his athletic achievements, Bekele invested in mentoring young athletes, sharing insights about training methods, mental resilience, and race strategy. He emphasized the importance of discipline, dedication, and national pride, inspiring both Ethiopian runners and athletes worldwide. His influence extended beyond performance metrics, shaping coaching techniques, training programs, and talent identification processes in Ethiopia and internationally. Bekele''s career demonstrated that success in long-distance running is the product of natural talent, methodical preparation, and a deep understanding of physiology, strategy, and mental focus. 

Kenenisa Bekele''s legacy continues to resonate in the world of athletics. He has set new benchmarks for performance, inspired a generation of Ethiopian runners, and reinforced Ethiopia''s status as a global powerhouse in distance running. His life story exemplifies the synergy of innate talent, disciplined training, and the pursuit of excellence, serving as a blueprint for aspiring athletes. Bekele''s achievements in the 5000m and 10000m, combined with his contributions to mentoring and athletics culture, ensure that his impact will endure for decades, cementing his place as one of the most influential and celebrated figures in the history of track and field.',
 'images/heroes/kenenisa_bekele.jpg'),


('Almaz Ayana', 1991, NULL, 3, 'Olympic runner',
 'Broke world record in 10000m at Rio 2016 Olympics.',
 'Almaz Ayana was born in 1991 in the high-altitude region of Sidama, Ethiopia, a community renowned for producing exceptional long-distance runners. From an early age, she displayed remarkable endurance, speed, and agility, participating in school competitions and local races, where her natural talent became evident. Encouraged by family and early coaches, Ayana committed herself to structured training programs that balanced physical conditioning, technique development, and mental preparation. Her early experiences running in challenging terrain, combined with disciplined coaching, provided a foundation for her exceptional aerobic capacity, endurance, and competitive intelligence, traits that would later define her career on the global stage.

As she progressed through junior and national competitions, Ayana demonstrated a rare combination of tactical intelligence, consistent pacing, and aggressive finishing speed. She quickly rose through the ranks of Ethiopian athletics, competing in international meets and gaining exposure to high-level competition. Her training emphasized interval workouts, high-mileage endurance runs, altitude adaptation, and strength conditioning, all tailored to optimize her performance in both 5000m and 10000m events. Coaches noted her exceptional ability to maintain a fast tempo over long distances while executing strategic surges, enabling her to dominate races and set new performance standards.  

Almaz Ayana''s crowning achievement came at the 2016 Rio Olympics, where she broke the world record in the 10,000m, completing the race with a combination of speed, stamina, and tactical mastery. Her victory was a culmination of years of disciplined training, careful race planning, and psychological resilience. The high-profile nature of the Olympic stage amplified the significance of her achievement, inspiring countless young athletes, particularly women, in Ethiopia and around the world. Her performance demonstrated that rigorous preparation, mental fortitude, and strategic intelligence can elevate natural talent to historic accomplishments.  

Beyond her Olympic success, Ayana continued to compete at the highest levels, participating in World Championships and Diamond League events, consistently achieving top performances and setting new benchmarks. Her contributions extended beyond athletic results; she became a role model for aspiring female athletes, emphasizing the importance of discipline, dedication, education, and perseverance. Ayana actively engaged in mentorship programs, sharing her experience and training insights with younger runners, encouraging them to pursue excellence and maintain balance in their personal and professional development.  

Almaz Ayana''s legacy is defined by her ability to combine extraordinary talent, scientific training, and mental resilience to achieve record-breaking performances, inspiring a generation of athletes to pursue long-distance running with ambition and discipline. Her achievements highlight the enduring strength of Ethiopian athletics, elevate the global profile of female long-distance runners, and demonstrate how individual dedication and national pride can create a lasting impact on sports culture. Today, her career continues to serve as an example of excellence, perseverance, and the transformative power of sport, ensuring that Almaz Ayana''s influence will resonate for decades within Ethiopia and across the world.',
 'images/heroes/almaz_ayana.jpg'),


('Yohannes IV', 1837, 1889, 2, 'Emperor and defender',
 'Defended Ethiopian independence against foreign invasions.',
 'Emperor Yohannes IV was born in 1837 in the Tigray region of northern Ethiopia, during a period of political fragmentation and regional conflict. From an early age, he displayed leadership qualities, strategic thinking, and a keen understanding of military and political dynamics, which were essential for survival in a highly fragmented feudal environment. Yohannes'' formative years involved training in both warfare and governance, and he developed alliances with local nobles and tribal leaders to strengthen his influence. These early experiences instilled in him the skills and determination necessary to rise to power and unify disparate Ethiopian states under a central authority.  

As he ascended to leadership, Yohannes IV worked tirelessly to consolidate power, bringing together various principalities and feudal territories through strategic alliances, diplomacy, and military campaigns. He emphasized the importance of central authority while balancing respect for local customs and religious traditions, particularly the Ethiopian Orthodox Church. His policies sought to maintain cohesion within the empire while defending sovereignty against external threats, creating a stable foundation for governance in a turbulent period. Yohannes demonstrated exceptional strategic acumen in his military campaigns, particularly against Egyptian forces seeking to expand into northern Ethiopia. He personally led troops, coordinated logistics, and implemented innovative tactics that leveraged terrain and local knowledge, ensuring the defense of Ethiopian territory. Similarly, he confronted the Mahdist incursions from Sudan, organizing coordinated defenses and rallying regional forces to resist invasions. These military achievements reinforced his reputation as a defender of Ethiopian independence and earned him the loyalty and respect of both soldiers and civilian populations.  

Beyond military accomplishments, Yohannes IV implemented administrative and religious policies to strengthen Ethiopia internally. He promoted Christianity as a unifying force, while also allowing for the coexistence of different regional traditions to maintain social harmony. His reforms in taxation, governance, and infrastructure helped stabilize the empire, while his support for the Ethiopian Orthodox Church reinforced cultural and spiritual cohesion. Yohannes'' leadership style combined firmness with pragmatism, and he understood the importance of diplomacy, negotiation, and alliance-building alongside military strength.  

Emperor Yohannes IV''s reign also involved significant engagement with foreign powers, negotiating treaties, and maintaining Ethiopia''s sovereignty in the face of colonial expansion in the Horn of Africa. He navigated complex international relations, balancing Ethiopian interests with the ambitions of Egypt, Britain, Italy, and neighboring states. His ability to maintain independence while fostering alliances demonstrated his sophisticated understanding of geopolitics and reinforced Ethiopia''s position as a sovereign nation during the Scramble for Africa.  

Yohannes IV''s legacy endures in Ethiopian history as a symbol of patriotic leadership, strategic brilliance, and steadfast defense of sovereignty. His accomplishments laid the groundwork for future emperors to build a unified and resilient Ethiopian state. Through military victories, administrative reforms, religious leadership, and diplomatic skill, he shaped the course of Ethiopian history, inspiring subsequent generations of leaders, soldiers, and citizens. His life exemplifies the integration of courage, intellect, and dedication in service to nationhood, leaving an enduring mark on Ethiopia''s identity, governance, and national pride.',
 'images/heroes/yohannes_iv.jpg'),


('Menelik II', 1844, 1913, 3, 'Emperor and modernizer',
 'Led Ethiopia to victory at the Battle of Adwa against Italy.',
 'Menelik II was born in 1844 in the Shewa region of Ethiopia, a period marked by political fragmentation and regional rivalries. From a young age, he was exposed to both the intricacies of Ethiopian court politics and the responsibilities of leadership, which shaped his strategic and administrative abilities. Early mentorship by family and court advisors cultivated in him a profound understanding of diplomacy, military strategy, and governance. Menelik''s formative years were defined by observation, training in military tactics, and engagement in regional politics, preparing him for eventual leadership at the national level.

Upon ascending to the throne, Menelik II embarked on a comprehensive modernization program for Ethiopia, recognizing the importance of strengthening the state to maintain independence in the face of European colonial ambitions. He reorganized the military, incorporating modern weaponry, training techniques, and organizational reforms to create a disciplined and effective fighting force. Infrastructure projects, including road construction, communication systems, and urban development, facilitated economic growth and administrative efficiency. Menelik also reformed taxation systems and governance structures, centralizing authority while maintaining respect for local traditions and leaders. These initiatives collectively enhanced Ethiopia''s capacity to resist foreign encroachment and to govern a diverse and geographically vast empire effectively.

Menelik II''s most celebrated achievement came in 1896 at the **Battle of Adwa**, where Ethiopian forces decisively defeated the Italian army attempting to colonize the country. Drawing on his military acumen, strategic alliances, knowledge of terrain, and disciplined army, Menelik coordinated a campaign that not only defended Ethiopian sovereignty but also became a symbol of African resistance to European colonialism. The victory at Adwa inspired anti-colonial movements across the continent and solidified Menelik''s reputation as a visionary and courageous leader. Beyond the battlefield, Menelik skillfully navigated diplomatic relations with European powers, securing recognition of Ethiopia''s independence and negotiating treaties that reinforced sovereignty while avoiding subjugation.

Menelik II''s leadership also extended to social, educational, and cultural initiatives. He supported the establishment of schools, promoted literacy, and encouraged the dissemination of knowledge throughout the empire. Religious and cultural policies aimed to unify the diverse populations of Ethiopia while maintaining respect for local traditions. Menelik''s combination of military prowess, administrative reforms, modernization efforts, and diplomacy enabled Ethiopia to emerge as a strong, sovereign nation capable of resisting colonial domination in a period when most African countries were being colonized.

The legacy of Menelik II endures as a model of visionary leadership, combining strategic intelligence, practical reforms, and national pride. His modernization initiatives laid the foundation for future economic and social development, while his decisive victory at the Battle of Adwa remains a symbol of Ethiopian resilience and independence. Menelik''s ability to navigate internal challenges and external threats ensured that Ethiopia maintained sovereignty, stability, and cohesion, setting a standard for African leadership in the era of colonial expansion. Through his policies, military achievements, and strategic vision, Menelik II left an indelible mark on Ethiopian history and on the broader narrative of African resistance and empowerment.',
 'images/heroes/menelik_ii.jpg'),


('Empress Taytu Betul', 1851, 1918, 3, 'Political leader',
 'Key strategist during the Battle of Adwa.',
 'Empress Taytu Betul was born in 1851 into a noble family in Ethiopia, where she was exposed from an early age to political leadership, diplomacy, and the responsibilities of elite governance. Educated in courtly traditions and cultural affairs, Taytu developed intelligence, strategic insight, and a deep understanding of Ethiopian political structures. Her upbringing prepared her for leadership roles in a period marked by both internal challenges and the growing threat of European colonial expansion in Africa. Taytu''s early life cultivated in her a profound sense of national pride and awareness of Ethiopia''s sovereignty, as well as the skills to navigate complex social and political networks.

Taytu Betul married Menelik II and became an indispensable partner in governance, providing counsel on diplomacy, administration, and military strategy. She actively participated in decision-making, advising on internal policies and the management of Ethiopia''s diverse regions. Empress Taytu was particularly influential in shaping strategies during times of foreign threat, using her intellect, foresight, and network of allies to coordinate responses to external pressures. Her insight extended to both domestic reforms and international relations, ensuring that Ethiopia maintained cohesion, stability, and sovereignty. 

One of Taytu''s most celebrated contributions was during the **Battle of Adwa** in 1896, when Ethiopian forces successfully repelled the Italian invasion. She was instrumental in planning logistics, troop movements, and strategy, ensuring that men and supplies were effectively organized to achieve a decisive victory. Her leadership demonstrated exceptional foresight and courage, earning respect among military commanders and civilians alike. Taytu''s influence extended beyond the battlefield, fostering unity among Ethiopian leaders, maintaining morale, and advocating for strategies that protected Ethiopia''s independence while preserving social stability.  

Empress Taytu also championed social reforms and cultural preservation. She promoted education, particularly for women, encouraged literacy programs, and supported cultural institutions that reinforced Ethiopian identity. Her actions emphasized the importance of women''s participation in governance and social development, serving as a model for female leadership in a traditionally male-dominated society. Taytu''s advocacy for women, combined with her active involvement in politics and military affairs, made her a unique figure in Ethiopian history, demonstrating that female leadership could be both strategic and transformative.  

The legacy of Empress Taytu Betul endures as a testament to intelligence, courage, and strategic acumen. She not only contributed to Ethiopia''s victory at Adwa and preservation of independence but also played a pivotal role in governance, social reform, and cultural preservation. Taytu''s life illustrates the power of visionary leadership and the vital role of women in shaping the course of history. Her contributions continue to inspire Ethiopians and the global community, highlighting the impact of determined, informed, and principled leadership in the face of internal and external challenges.',
 'images/heroes/taytu_betul.jpg'),


('Shewareged Gedle', 1883, 1950, 3, 'Freedom fighter', 
 'A legendary patriot leader known for organizing internal resistance and supplying arms to fighters.', 
 'Shewareged Gedle was born in 1883 in a rural region of Ethiopia during a period marked by local conflicts, feudal rivalries, and the increasing threat of foreign encroachment. From an early age, Gedle displayed remarkable leadership qualities, courage, and an acute understanding of strategy and social networks. He observed the hardships faced by his community under the pressures of internal disputes and external threats, instilling in him a profound sense of patriotism and responsibility toward protecting Ethiopia''s sovereignty. Gedle''s upbringing provided him with the knowledge of local terrain, social alliances, and the organization of community resources, which would later be critical to his role as a freedom fighter.

As Gedle matured, he became increasingly involved in coordinating resistance against foreign forces, particularly during periods of Italian occupation. He recognized the importance of organized, decentralized efforts to mobilize local communities while maintaining operational security. Gedle became an expert in guerrilla tactics, training fighters, coordinating movements across challenging terrain, and establishing supply chains for weapons, food, and medical support. His strategic insight enabled Ethiopian patriots to launch effective operations against occupying forces, maximizing impact while minimizing unnecessary risk. Gedle also emphasized the importance of morale, leadership, and loyalty among his forces, ensuring cohesion even in adverse conditions.  

Beyond tactical operations, Shewareged Gedle worked to inspire local populations, conveying messages of unity, national pride, and the importance of resisting foreign domination. He organized community meetings, shared intelligence, and fostered networks that allowed villages and towns to contribute to the resistance effort. His leadership created a sense of collective responsibility and reinforced cultural identity, which strengthened both local resilience and national solidarity. Gedle''s influence extended beyond immediate military outcomes, cultivating a generation of Ethiopians committed to defending their homeland, understanding strategy, and participating actively in governance and civic life.  

Gedle''s legacy includes his role as a symbol of courage, patriotism, and strategic brilliance. His ability to organize effective resistance operations, sustain morale, and inspire national pride contributed significantly to Ethiopia''s ongoing struggle for sovereignty and self-determination. He remains celebrated in Ethiopian collective memory as a model of leadership, determination, and commitment to freedom. Stories of his exploits, strategic planning, and mentorship continue to inform contemporary narratives of resistance, national identity, and the values of courage and community engagement.  

Through his lifelong dedication, Shewareged Gedle demonstrated the power of organized grassroots resistance, the importance of leadership in times of crisis, and the enduring impact of individual and collective action on national survival. His story exemplifies how vision, courage, and strategic thinking can transform local knowledge into organized, effective movements that safeguard cultural and national integrity, leaving an indelible mark on Ethiopia''s history.',
 'images/heroes/shewareged_gedle.jpg'),


('Zewditu', 1876, 1930, 3, 'Empress of Ethiopia',
 'First female monarch of the Ethiopian Empire.',
 'Empress Zewditu was born in 1876 into the royal family of Ethiopia, during a period of dynastic and regional complexities. From a young age, she was exposed to court politics, religious traditions, and the responsibilities of leadership within a feudal empire. Her upbringing combined formal education in royal affairs, Ethiopian Orthodox Christianity, and cultural training, cultivating intelligence, diplomacy, and a sense of duty toward her people. These early experiences shaped Zewditu''s understanding of governance, the balancing of tradition and reform, and the importance of moral authority in leadership.

Zewditu ascended to the Ethiopian throne as the first female monarch in the early 20th century, a historic milestone that challenged prevailing gender norms while emphasizing continuity of dynastic legitimacy. Her reign required navigating a complex political landscape, balancing the influence of powerful nobles, the church, and regional governors. Empress Zewditu implemented administrative reforms that strengthened centralized authority while respecting local customs, ensuring stability across a diverse empire. She carefully managed succession issues, diplomatic relations, and governance priorities, demonstrating prudence, patience, and strategic foresight in her decision-making.

During her reign, Zewditu worked to maintain Ethiopia''s sovereignty amid growing international pressures while promoting internal modernization. She emphasized education, judicial reforms, and infrastructure improvements while upholding religious and cultural traditions that fostered national unity. Her policies reflected a nuanced approach to governance: respecting tradition while gradually introducing reforms to enhance administrative efficiency, social cohesion, and national resilience. Empress Zewditu also supported religious institutions, recognizing their central role in Ethiopian society and their influence on ethical, cultural, and civic life. 

Zewditu''s leadership exemplified the integration of female authority into a historically male-dominated monarchy. She became a symbol of women''s potential for governance, demonstrating that leadership could combine moral integrity, strategic acumen, and dedication to the public good. Her reign inspired subsequent generations of Ethiopian women to participate in social, political, and cultural spheres, highlighting the importance of representation and empowerment in sustaining societal progress. 

The legacy of Empress Zewditu endures through her contributions to governance, cultural preservation, and female leadership in Ethiopia. Her careful balancing of tradition and modernization, coupled with her commitment to stability, religious guidance, and administrative reform, left a lasting imprint on Ethiopian history. Zewditu remains celebrated as a pioneering figure who shaped the course of the empire, fostered national cohesion, and provided a model of female authority, demonstrating the enduring power of principled and strategic leadership.',
'images/heroes/empress_zewditu.jpg'),

('Aklilu Habte-Wold', 1912, 1974, 3, 'Prime Minister of Ethiopia',
 'Served as Prime Minister under Emperor Haile Selassie.',
 'Aklilu Habte-Wold was born in 1912 in Ethiopia and became one of the most influential political leaders during the reign of Emperor Haile Selassie. Educated both in Ethiopia and abroad, Aklilu displayed exceptional administrative skill from an early age, mastering both diplomacy and governance. During his tenure as Prime Minister from 1961 to 1974, he played a pivotal role in modernizing government institutions and implementing infrastructural projects aimed at improving the economic, educational, and social landscape of Ethiopia. His leadership coincided with a period of rapid change and tension, as the country faced pressures both from within and from external political forces. Aklilu managed the delicate balance of authority between the monarchy and local leaders while promoting industrialization, modernization of the civil service, and reforms in the education system. He also emphasized foreign relations, seeking to strengthen Ethiopia''s position on the global stage and secure aid for development projects. Known for his cautious diplomacy and strategic decision-making, Aklilu navigated crises ranging from political dissent to regional conflicts, leaving a mixed but significant legacy of progress and administrative efficiency. Despite his accomplishments, his career ended abruptly during the 1974 revolution, marking a turning point in Ethiopia''s modern history. His life and work remain a testament to the challenges and opportunities of governance during a critical transitional period.',
'images/heroes/aklilu_habte_wold.jpg'),

('Lucy (Australopithecus afarensis)', -3200000, NULL, 1, 'Ancient Hominid Fossil',
 'Famous fossil that provided insight into early human evolution in Ethiopia.',
 'Lucy, discovered in 1974 in the Afar region of Ethiopia, is one of the most remarkable fossils in human evolutionary history. Belonging to the species Australopithecus afarensis, she lived approximately 3.2 million years ago. Lucy''s skeletal remains provided groundbreaking evidence for bipedalism, confirming that walking upright preceded significant brain enlargement in hominid evolution. Her discovery transformed the understanding of human ancestry and placed Ethiopia at the center of paleoanthropological research. The meticulous excavation and analysis revealed that Lucy stood about 1.1 meters tall and weighed roughly 29 kilograms, suggesting adaptations suitable for both climbing and walking. Her skeletal structure offered clues about locomotion, physical endurance, and daily survival in the environment of prehistoric East Africa. Lucy''s discovery prompted numerous studies on other fossils, the dating of geological layers, and reconstructions of early hominid social behaviors, dietary patterns, and ecological adaptations. Her significance extends beyond science; Lucy became an international symbol of Ethiopia''s rich contributions to understanding human origins and inspired generations of researchers and educators worldwide.',
'images/heroes/lucy.jpg'),

('Tsehaytu Beraki', 1939, 2018, 3, 'Eritrean/Ethiopian Artist & Musician',
 'Renowned singer, poet, and cultural icon of Eritrean/Ethiopian heritage.',
 'Tsehaytu Beraki was born in 1939 in Eritrea and became an internationally celebrated singer, poet, and cultural ambassador. Her life and career reflected a deep commitment to cultural preservation, artistic excellence, and social advocacy. She gained renown for her lyrical compositions, which often addressed themes of social justice, national identity, and the struggles of everyday people. Tsehaytu''s music was deeply intertwined with the oral traditions and historical narratives of the Horn of Africa, drawing on centuries-old melodies, instruments, and poetic forms. Over decades, she performed both locally and internationally, raising awareness of Eritrean and Ethiopian cultural heritage while promoting peace and human rights. Her performances were not only artistic expressions but also acts of education and political engagement, fostering dialogue and unity among diverse communities. Tsehaytu also mentored younger artists, helping preserve traditional music while encouraging innovation and creativity. Through her lifetime, she became a symbol of resilience, creativity, and dedication to cultural identity, leaving a lasting legacy that continues to inspire musicians, activists, and scholars alike.',
'images/heroes/tsehaytu_beraki.jpg'),

('Haile Gebrselassie', 1973, NULL, 3, 'Legendary Long-Distance Runner',
 'Multiple Olympic gold medalist and world record holder from Ethiopia.',
 'Haile Gebrselassie, born in 1973 in Ethiopia, is one of the greatest long-distance runners in history. His athletic career began in the highlands of Ethiopia, where he developed exceptional endurance and speed. Haile''s achievements include multiple Olympic gold medals, numerous World Championship victories, and several world records in both track and road events. He dominated events ranging from 5,000 meters to marathons, showcasing extraordinary physical and mental discipline. Beyond sports, Haile became a philanthropist and entrepreneur, founding schools, sports programs, and businesses in Ethiopia to promote education, health, and sustainable development. His life story embodies perseverance, national pride, and the transformative power of sports in inspiring social change. Haile''s impact transcends athletics; he is a role model for youth worldwide, demonstrating how talent, dedication, and vision can create a legacy that unites communities, uplifts nations, and inspires generations. His biography includes numerous awards, honors, and recognitions that celebrate his enduring contributions to both athletics and society.',
'images/heroes/haile_gebrselassi.jpg'),

('Liya Kebede', 1978, NULL, 3, 'Model and Maternal Health Advocate',
 'Supermodel and global advocate for maternal and child health from Ethiopia.',
 'Liya Kebede, born in 1978 in Ethiopia, is a world-renowned model, actress, and humanitarian. She began her career in fashion, quickly rising to international acclaim and gracing covers of leading magazines. Beyond her modeling achievements, Liya founded the Liya Kebede Foundation, focusing on improving maternal and child health in Ethiopia and other developing countries. Her work has promoted access to healthcare, education, and empowerment programs for women and children. 

Throughout her career, Liya has blended public influence with activism, advocating for health equity, cultural awareness, and sustainable development. She has partnered with global organizations, governments, and NGOs to implement programs that address maternal mortality, nutrition, and early childhood education. Liya''s impact extends far beyond the runway; she is celebrated as a pioneer who combines professional excellence with social responsibility. Her story inspires young women worldwide to pursue leadership, advocacy, and creativity, leaving a legacy of compassion, dedication, and positive change.',
'images/heroes/liya_kebede.jpg'),


('Yirgalem Fisseha', 1981, NULL, 3, 'Poet and Journalist',
 'Award-winning Ethiopian poet and human rights advocate.',
 'Yirgalem Fisseha is a contemporary Ethiopian poet, writer, and journalist known for her powerful literary voice and advocacy for freedom of expression. Her works explore themes of identity, justice, and resilience, reflecting the experiences of modern Ethiopian society. Despite facing political challenges, including imprisonment, she continued to write and inspire others through her courage and creativity. Her poetry has gained international recognition, making her one of the leading literary figures of her generation.',
'images/heroes/yirgalem_fisseha.jpg'),


('Zeresenay Alemseged', 1969, NULL, 3, 'Paleoanthropologist',
 'Scientist known for discovering Selam fossil.',
 'Zeresenay Alemseged is an Ethiopian paleoanthropologist recognized globally for his discovery of Selam, a remarkably complete child fossil of Australopithecus afarensis. His research has significantly contributed to understanding human evolution and early childhood development in ancient hominids. Through fieldwork and academic leadership, he has elevated Ethiopia''s role in global scientific research.',
'images/heroes/zeresenay_alemseged.jpg'),

('Emperor Lalibela', 1162, 1221, 2, 'Zagwe Dynasty King',
 'Known for rock-hewn churches of Lalibela.',
 'Emperor Lalibela was a ruler of the Zagwe dynasty and is best known for commissioning the rock-hewn churches in Lalibela, Ethiopia. These architectural masterpieces were carved directly into rock and remain one of the most significant religious and historical sites in the world. His vision created a spiritual center that continues to attract pilgrims and visitors globally.',
'images/heroes/lalibela.jpg'),

('Mulatu Astatke', 1943, NULL, 3, 'Father of Ethio-jazz',
 'Musician who created Ethio-jazz genre.',
 'Mulatu Astatke is a pioneering Ethiopian musician credited with creating Ethio-jazz, a unique fusion of traditional Ethiopian music with jazz and Latin rhythms. His work has influenced generations of musicians worldwide and introduced Ethiopian sound to global audiences. His compositions remain timeless and culturally significant.',
'images/heroes/mulatu_astatke.jpg'),

('Abel Tesfaye (The Weeknd)', 1990, NULL, 3, 'Global Music Artist',
 'Internationally famous singer with Ethiopian roots.',
 'Abel Tesfaye, known professionally as The Weeknd, is a globally acclaimed artist with Ethiopian heritage. His music blends R&B, pop, and electronic influences, earning him numerous awards and worldwide recognition. Beyond music, he has contributed to humanitarian causes and represented Ethiopian culture on the global stage.',
'images/heroes/the_weeknd.jpg'),

('Haddis Alemayehu', 1910, 2003, 3, 'Writer and Diplomat',
 'Author of the famous novel Fiqir Eske Mekabir.',
 'Haddis Alemayehu was a prominent Ethiopian writer, diplomat, and intellectual whose works contributed significantly to Ethiopian literature and education. His novel Fiqir Eske Mekabir is considered one of the greatest works in Amharic literature. Through his writings and public service, he helped shape modern Ethiopian intellectual thought and inspired generations of students and scholars.',
'images/heroes/haddis_alemayehu.jpg'),


('Richard Pankhurst', 1927, 2017, 3, 'Historian of Ethiopia',
 'Renowned historian and scholar of Ethiopian studies.',
 'Richard Pankhurst was a British-born Ethiopian historian who dedicated his life to studying and documenting Ethiopia''s history, culture, and economy. He taught at Addis Ababa University and authored numerous books and research papers that became foundational references for Ethiopian studies. His contributions greatly enriched academic knowledge and education in Ethiopia.',
'images/heroes/richard_pankhurst.jpg'),

('Tsegaye Gabre-Medhin', 1936, 2006, 3, 'Playwright and Poet',
 'Ethiopian laureate known for literary and educational contributions.',
 'Tsegaye Gabre-Medhin was a renowned Ethiopian playwright, poet, and educator whose works influenced Ethiopian literature and education. He served as Poet Laureate and contributed to the development of cultural and educational institutions. His writings emphasized history, identity, and human values, making him an influential intellectual figure.',
'images/heroes/tsegaye_gabre_medhin.jpg'),

('Mesfin Woldemariam', 1930, 2020, 3, 'Professor and Activist',
 'Geography professor and human rights advocate.',
 'Mesfin Woldemariam was a respected Ethiopian professor, scholar, and human rights activist. As a founding member of the Ethiopian Human Rights Council, he advocated for democracy, justice, and education. His academic work and activism inspired students and citizens to engage critically with social and political issues.',
'images/heroes/mesfin_woldemariam.jpg'),

('Bahru Zewde', 1947, NULL, 3, 'Historian and Academic',
 'Leading Ethiopian historian and professor.',
 'Bahru Zewde is one of Ethiopia''s most respected historians and academics. His research and publications have shaped the understanding of Ethiopian history, particularly modern political and social developments. As a professor, he has mentored many students and contributed to strengthening higher education in Ethiopia.',
'images/heroes/bahru_zewde.jpg'),

('Segenet Kelemu', 1957, NULL, 3, 'Molecular Biologist',
 'Leading scientist in plant pathology and biotechnology.',
 'Segenet Kelemu is an internationally recognized Ethiopian molecular biologist specializing in plant pathology and biotechnology. Her research has contributed to improving food security by developing sustainable agricultural solutions. She has held leadership positions in global scientific organizations and has been recognized for advancing science in Africa and empowering women in STEM.',
'images/heroes/segenet_kelemu.jpg'),

('Tilahun Yilma', 1944, NULL, 3, 'Veterinary Scientist',
 'Known for vaccine research and biotechnology.',
 'Tilahun Yilma is a pioneering Ethiopian scientist known for his work in veterinary medicine and biotechnology. He played a key role in developing vaccines for livestock diseases, contributing to improved agricultural productivity and food security. His academic and research contributions have had global impact, particularly in Africa.',
'images/heroes/tilahun_yilma.jpg'),

('Mulat Demeke', 1959, NULL, 3, 'Economist and Policy Expert',
 'Expert in agricultural economics and food security.',
 'Mulat Demeke is an Ethiopian economist and academic known for his expertise in agricultural policy, food security, and economic development. He has worked with international organizations and contributed to policy-making that supports sustainable development and poverty reduction in Ethiopia and beyond.',
'images/heroes/mulat_demeke.jpg'),

('Fikre Tolossa', 1938, 2020, 3, 'Scholar and Literary Critic',
 'Professor known for contributions to African literature studies.',
 'Fikre Tolossa was an Ethiopian scholar, professor, and literary critic whose work focused on African and Ethiopian literature. He contributed to academic research and education, mentoring students and advancing literary scholarship. His work helped shape modern academic discussions on African identity and culture.',
'images/heroes/fikre_tolossa.jpg'),

('Yohannes Haile-Selassie', 1961, NULL, 3, 'Paleoanthropologist',
 'Researcher on early human ancestors in Ethiopia.',
 'Yohannes Haile-Selassie is a leading Ethiopian paleoanthropologist known for his discoveries of early hominid fossils in the Afar region. His research has expanded understanding of human evolution and Ethiopia''s role as a cradle of humanity. He has contributed extensively to academic research and global scientific knowledge.',
'images/heroes/yohannes_haile_selassie.jpg'),

('Rediet Abebe', 1991, NULL, 3, 'Computer Scientist',
 'AI researcher and professor at UC Berkeley.',
 'Rediet Abebe is an Ethiopian computer scientist specializing in artificial intelligence, algorithms, and the intersection of computing with social good. She became one of the youngest professors at UC Berkeley and has conducted groundbreaking research on fairness in algorithms, data science, and economic inequality. Her work focuses on using technology to solve real-world societal challenges.',
'images/heroes/rediet_abebe.jpg'),

('Betelhem Dessie', 1999, NULL, 3, 'Software Engineer',
 'Young Ethiopian tech innovator and AI enthusiast.',
 'Betelhem Dessie is a prominent Ethiopian software engineer and technology leader who began coding at a young age. She has worked on AI, robotics, and youth tech empowerment initiatives. As a role model for young Africans, she promotes STEM education and digital innovation across the continent.',
'images/heroes/betelhem_dessie.jpg'),

('Abiy Ahmed', 1976, NULL, 3, 'Prime Minister and Reformer',
 'Abiy Ahmed, born in 1976, became Ethiopia''s Prime Minister in 2018, implementing major political and economic reforms.',
 'Abiy Ahmed was born on August 15, 1976, in Beshasha, Gomma district, in the Jimma Zone of the Oromia region. He grew up in a diverse cultural environment, as his father was an Oromo Muslim and his mother an Amhara Christian, giving him an early understanding of Ethiopia''s multi-ethnic and multi-religious society. His childhood was marked by the complexities of the Ethiopian political landscape, including the aftermath of the Derg regime and ongoing regional conflicts, which instilled in him a deep awareness of the importance of unity and national identity.  

From a young age, Abiy exhibited curiosity, discipline, and leadership potential. He excelled in school, particularly in sciences and languages, demonstrating both analytical skills and communication abilities. In his teens, he became involved with the Ethiopian People''s Revolutionary Democratic Front (EPRDF), inspired by the idea of shaping Ethiopia''s future through both civic engagement and military service. His early exposure to political ideology, grassroots activism, and community service shaped his worldview and laid the foundation for his later role in national leadership.  

Abiy Ahmed pursued higher education rigorously, earning a Bachelor''s degree in Computer Engineering from Microlink Information Technology College in Addis Ababa. He later obtained a Master''s degree in Transformational Leadership and Change from the University of Greenwich in London, followed by a PhD in Peace and Security Studies from Addis Ababa University. His education reflected a blend of technical, managerial, and diplomatic knowledge, equipping him to navigate complex national and international challenges.  

In the military, Abiy rose through the ranks of the Ethiopian National Defense Force, participating in critical operations that strengthened national security and enhanced his strategic thinking. His service emphasized discipline, resilience, and the ability to coordinate large teams under pressure. These experiences informed his approach to governance, highlighting the value of strategic planning, decisive action, and conflict resolution in achieving lasting results.  

Abiy''s political career formally began with his election to the House of Peoples'' Representatives and subsequent appointments within the Oromia regional government. His pragmatic approach, focus on youth empowerment, and dedication to national reform earned him recognition and trust across political lines. In 2018, he became Prime Minister of Ethiopia, assuming leadership at a time of political tension, economic stagnation, and regional instability.  

As Prime Minister, Abiy launched sweeping reforms designed to modernize the political system, enhance economic growth, and foster social cohesion. He released political prisoners, lifted bans on opposition groups, and implemented policies encouraging media freedom and civic participation. He focused on technological innovation, introducing digital infrastructure projects, improving internet accessibility, and promoting entrepreneurship. Abiy''s administration emphasized public-private partnerships and sustainable development to create long-term economic stability.  

A landmark achievement of Abiy Ahmed''s leadership was the historic peace agreement with Eritrea, ending a decades-long conflict that had shaped regional geopolitics. Through careful negotiation, diplomacy, and reconciliation efforts, Abiy restored relations, reopened borders, and fostered trade opportunities, earning him the Nobel Peace Prize in 2019. This achievement highlighted his skills in diplomacy, conflict resolution, and visionary leadership, solidifying his reputation internationally.  

Abiy also confronted internal challenges, including ethnic tensions and regional disputes. He worked to balance the aspirations of Ethiopia''s diverse populations with national unity, navigating complex political landscapes with dialogue, compromise, and legal reforms. While controversies and difficulties arose, Abiy consistently emphasized reform, accountability, and modernization as central pillars of his administration.  

Beyond politics, Abiy is known for engaging with citizens directly, attending public forums, listening to youth concerns, and promoting cultural inclusivity. His personal interests in literature, music, and technology have helped him connect with a younger generation, fostering hope for a modern, innovative Ethiopia.  

Abiy Ahmed''s legacy is still in formation but already demonstrates a remarkable integration of military discipline, academic rigor, visionary reform, and diplomatic achievement. He represents a new era of Ethiopian leadership, combining national pride with forward-looking policies that seek to unify a historically diverse nation while positioning it for global relevance. His story inspires future leaders to embrace education, courage, and ethical responsibility in serving their country.',
'images/heroes/abiy_ahmed.jpg'),

('Eleni Gabre-Madhin', 1965, NULL, 3, 'Economist and Market Innovator',
 'Eleni Gabre-Madhin is a leading economist who transformed Ethiopia''s commodity exchange system.',
 'Eleni Gabre-Madhin was born in 1965 in Addis Ababa, Ethiopia, during a time of political and economic transition following the Derg regime. Growing up, she witnessed the challenges faced by farmers and local markets, including unstable prices, lack of access to modern infrastructure, and limited support for agricultural development. These early observations deeply influenced her later career and dedication to improving Ethiopia''s economic systems.  

From a young age, Eleni demonstrated remarkable analytical skills and a keen interest in economics, agriculture, and social development. She excelled academically, showing a natural aptitude for problem-solving and innovation. Motivated by a desire to contribute meaningfully to her country, she pursued higher education abroad, earning advanced degrees in economics and business management. Her international exposure equipped her with both theoretical knowledge and practical insights into global market systems, trade mechanisms, and financial management.  

After completing her studies, Eleni returned to Ethiopia with a mission to transform the agricultural sector. She recognized that fragmented markets, lack of transparency, and inconsistent pricing were major obstacles preventing farmers from achieving sustainable livelihoods. Drawing on her expertise, she conceptualized the idea of a modern commodity exchange—a centralized system that would standardize trading, provide reliable information, and ensure fair pricing for all participants.  

In 2008, Eleni Gabre-Madhin founded the **Ethiopia Commodity Exchange (ECX)**, a pioneering initiative that revolutionized how agricultural products were traded in Ethiopia. The ECX introduced standardized contracts, warehouse receipts, and real-time market information, creating transparency and trust between farmers, buyers, and investors. By connecting rural producers with urban and international markets, the exchange empowered farmers to negotiate better prices, reduce post-harvest losses, and gain access to credit facilities.  

Eleni''s work at ECX reflected a rare combination of economic acumen, technological understanding, and social responsibility. She led a multidisciplinary team that developed digital platforms, logistics systems, and regulatory frameworks to ensure the exchange''s effectiveness and sustainability. Her leadership style emphasized collaboration, innovation, and capacity building, enabling local staff to manage complex operations while adhering to international standards.  

Under her guidance, the ECX expanded rapidly, handling millions of transactions annually and covering commodities such as coffee, sesame, maize, and wheat. The system improved transparency in the agricultural supply chain, reduced exploitation of smallholder farmers, and attracted foreign investment. By promoting data-driven decision-making, Eleni created an environment where farmers could make informed choices about production, storage, and marketing.  

Beyond her technical achievements, Eleni became an advocate for women in economics and leadership roles. She encouraged female participation in market governance, financial services, and entrepreneurial ventures, addressing systemic inequalities in Ethiopia''s economic landscape. Through workshops, mentorship programs, and policy engagement, she inspired a new generation of women leaders and economists to pursue careers in sectors traditionally dominated by men.  

Eleni Gabre-Madhin''s influence extended beyond Ethiopia. She participated in international forums, advising governments, NGOs, and multilateral organizations on commodity market development, food security, and economic growth strategies. Her expertise in designing transparent, efficient, and inclusive market systems gained recognition globally, positioning her as a thought leader in emerging economies.  

Her personal qualities—vision, persistence, and ethical leadership—played a central role in overcoming challenges. Implementing a national-level commodity exchange required navigating bureaucratic hurdles, skepticism from stakeholders, and technological limitations. Eleni''s ability to communicate the benefits of ECX, build trust among farmers and traders, and integrate modern technology into traditional systems was instrumental in its success.  

Through her lifelong dedication, Eleni Gabre-Madhin transformed Ethiopia''s agricultural economy, empowering farmers, strengthening markets, and promoting sustainable growth. Her work exemplifies how innovative thinking, applied economics, and leadership can create tangible impact at both local and national levels. Eleni''s legacy is not only the successful ECX but also the demonstration that visionary women can drive systemic change in Africa''s development sector.  

Eleni continues to mentor young economists, consult on market development projects, and advocate for economic systems that are transparent, equitable, and future-focused. Her career reflects a fusion of technical mastery, social commitment, and forward-thinking innovation, making her one of Ethiopia''s most influential modern leaders and a model for emerging economies worldwide.',
'images/heroes/eleni_gabre_madhin.jpg'),

('Dereje Agonafer', 1950, NULL, 3, 'Engineer and Academic Leader',
 'Dereje Agonafer is a renowned engineer and academic, contributing to global engineering research and education.',
 'Dereje Agonafer was born in 1950 in Addis Ababa, Ethiopia, during a period of rapid social and infrastructural development, though Ethiopia was still grappling with political instability and modernization challenges. From a young age, Dereje displayed a keen interest in mathematics, physics, and mechanical systems, showing an aptitude for problem-solving and technical innovation. His early education exposed him to foundational concepts in science and engineering, sparking a lifelong commitment to research and academic excellence.  

After completing his secondary education, Dereje pursued higher studies abroad, earning advanced degrees in mechanical and thermal engineering. His studies focused on the principles of heat transfer, energy systems, and engineering design, equipping him with the skills necessary to tackle complex industrial and technological challenges. During this period, he cultivated a global perspective, learning best practices from leading research institutions and integrating them with a vision for contributing to Ethiopia''s technological advancement.  

Upon returning to Ethiopia, Dereje embarked on an academic career dedicated to teaching, research, and institutional development. He became a professor and researcher, mentoring students in mechanical and thermal engineering, guiding their projects, and fostering a culture of innovation and excellence. Dereje''s commitment to education was paralleled by his ambition to apply engineering solutions to practical problems, particularly in energy management, industrial efficiency, and technology infrastructure.  

Dereje Agonafer''s research contributions are internationally recognized, particularly in the fields of thermal management, heat transfer, and energy systems. He has authored numerous scholarly articles, presented at global conferences, and collaborated with international research teams to advance engineering knowledge. His work has informed industrial design, electronics cooling systems, and sustainable energy solutions, demonstrating the practical impact of academic research on everyday life.  

Beyond research, Dereje played a pivotal role in strengthening engineering education in Ethiopia and across Africa. He contributed to curriculum development, the establishment of research laboratories, and partnerships with global universities. Through mentorship programs, he nurtured a generation of engineers and academics who continue to advance science and technology in Ethiopia and internationally.  

Dereje''s career has been marked by a focus on integrating theoretical knowledge with practical application. He worked with industries to implement energy-efficient technologies, optimize production processes, and develop solutions to infrastructure challenges. His approach emphasized innovation, sustainability, and long-term problem-solving, bridging the gap between academia and real-world engineering applications.  

His leadership extends beyond research and education. Dereje has been involved in professional organizations, advisory boards, and technical committees, influencing policy and strategy in engineering, technology, and higher education. He is recognized for his integrity, vision, and ability to inspire collaboration among diverse stakeholders.  

Throughout his life, Dereje Agonafer has exemplified the role of a modern engineer and academic leader: combining rigorous research, practical innovation, mentorship, and institution-building. His contributions have enhanced Ethiopia''s technological capabilities, empowered students and professionals, and elevated the visibility of African engineers in global forums.  

Dereje''s legacy is enduring. He continues to mentor, publish research, and advise on technological initiatives, leaving an indelible mark on engineering education, sustainable technology development, and the scientific community in Ethiopia and beyond. His life demonstrates how vision, dedication, and applied knowledge can transform both individuals and national capacity, inspiring future generations to pursue excellence in science, engineering, and leadership.',
'images/heroes/dereje_agonafer.jpg'),

('Sossina Haile', 1974, NULL, 3, 'Materials Scientist and Engineer',
 'Sossina Haile is a leading materials scientist known for her work on fuel cells and sustainable energy technologies.',
 'Sossina Haile was born in 1974 in Addis Ababa. She pursued materials science, earning degrees in chemistry and engineering. She specializes in solid acid fuel cells and has received international recognition for her innovative research, advancing sustainable energy solutions and inspiring young scientists globally.',
 'images/heroes/sossina_haile.jpg'),

('Brook Lakew', 1965, NULL, 3, 'NASA Scientist and Aerospace Engineer',
 'Dr. Brook Lakew works at NASA, contributing to aerospace research and space science.',
 'Born in 1965 in Ethiopia, Dr. Brook Lakew excelled in physics and aerospace engineering. After earning advanced degrees abroad, he joined NASA, working on satellite technology and space missions. His contributions highlight Ethiopian excellence in STEM and global scientific collaboration.',
 'images/heroes/brook_lakew.jpg'),

('Berhane Asfaw', 1954, NULL, 3, 'Paleoanthropologist and Researcher',
 'Berhane Asfaw is a leading paleoanthropologist, known for his discoveries in human evolution.',
 'Berhane Asfaw was born in 1954 in Ethiopia. He has played a pivotal role in fossil discoveries in the Afar region, including hominid remains that transformed understanding of human origins. His research emphasizes fieldwork, scientific rigor, and mentoring young Ethiopian scientists.',
 'images/heroes/berhane_asfaw.jpg')
ON CONFLICT (name, birth_year) DO NOTHING;

INSERT INTO HeroImages (hero_id, image_url, caption) VALUES
(1, 'images/heroes/abebe_bikila_2.jpg', 'Abebe running barefoot in 1960 Rome Olympics'),
(2, 'images/heroes/tirunesh_dibaba_2.jpg', 'Tirunesh winning gold medal'),
(3, 'images/heroes/derartu_tulu_2.jpg', 'Derartu at Barcelona Olympics'),
(4, 'images/heroes/haile_selassie_2.jpg', 'Haile Selassie addressing the nation'),
(5, 'images/heroes/tewodros_ii_2.jpg', 'Emperor Tewodros II in military uniform'),
(6, 'images/heroes/belay_zeleke_2.jpg', 'Belay Zeleke during resistance efforts'),
(7, 'images/heroes/afework_tekle_2.jpg', 'Afework Tekle painting in studio'),
(8, 'images/heroes/melaku_worede_2.jpg', 'Melaku Worede inspecting crop varieties'),
(9, 'images/heroes/kitaw_ejigu_2.jpg', 'Kitaw Ejigu in aerospace lab'),
(10, 'images/heroes/bogaletch_gebre_2.jpg', 'Bogaletch Gebre at advocacy event'),
(11, 'images/heroes/aklilu_lemma_2.jpg', 'Aklilu Lemma demonstrating Endod plant use'),
(12, 'images/heroes/mamo_wolde_2.jpg', 'Mamo Wolde winning marathon'),
(13, 'images/heroes/gebisa_ejeta_2.jpg', 'Gebisa Ejeta in research field'),
(14, 'images/heroes/kenenisa_bekele_2.jpg', 'Kenenisa Bekele at finish line'),
(15, 'images/heroes/almaz_ayana_2.jpg', 'Almaz Ayana breaking world record'),
(16, 'images/heroes/yohannes_iv_2.jpg', 'Emperor Yohannes IV in palace'),
(17, 'images/heroes/menelik_ii_2.jpg', 'Menelik II at Battle of Adwa'),
(18, 'images/heroes/taytu_betul_2.jpg', 'Empress Taytu during council meeting'),
(19, 'images/heroes/shewareged_gedle_2.jpg', 'Shewareged leading patriots'),
(20, 'images/heroes/empress_zewditu_2.jpg', 'Empress Zewditu during official ceremony')
ON CONFLICT (hero_id, image_url) DO NOTHING;

INSERT INTO HeroCategories (hero_id, category_id) VALUES
-- Original 20 Heroes
(1,1),   -- Abebe Bikila → Athlete
(2,1),   -- Tirunesh Dibaba → Athlete
(3,1),   -- Derartu Tulu → Athlete
(4,4),   -- Haile Selassie → Leader
(5,4),   -- Tewodros II → Leader
(6,8),   -- Belay Zeleke → Freedom Fighter
(7,5),   -- Afework Tekle → Artist
(8,2),   -- Melaku Worede → Scientist
(9,7),   -- Kitaw Ejigu → Engineer
(10,6),  -- Bogaletch Gebre → Activist
(11,3),  -- Aklilu Lemma → Doctor
(12,2),  -- Gebisa Ejeta → Scientist
(13,1),  -- Mamo Wolde → Athlete
(14,1),  -- Kenenisa Bekele → Athlete
(15,1),  -- Almaz Ayana → Athlete
(16,4),  -- Yohannes IV → Leader
(17,4),  -- Menelik II → Leader
(18,4),  -- Empress Taytu Betul → Leader
(19,8),  -- Shewareged Gedle → Freedom Fighter
(20,4),  -- Zewditu → Leader

(21,4),  -- Aklilu Habte-Wold → Leader
(22,1),  -- Lucy → Scientist (Anthropology)
(23,5),  -- Tsehaytu Beraki → Artist
(24,1),  -- Haile Gebrselassie → Athlete
(25,5),  -- Liya Kebede → Artist / Activist

(26,5),  -- Yirgalem Fisseha → Artist
(27,2),  -- Zeresenay Alemseged → Scientist
(28,4),  -- Emperor Lalibela → Leader
(29,5),  -- Mulatu Astatke → Artist
(30,5),  -- Abel Tesfaye → Artist

(31,9),  -- Haddis Alemayehu → Educator
(32,9),  -- Richard Pankhurst → Educator
(33,9),  -- Tsegaye Gabre-Medhin → Educator
(34,9),  -- Mesfin Woldemariam → Educator
(35,9),  -- Bahru Zewde → Educator

(36,2),  -- Segenet Kelemu → Scientist
(37,2),  -- Tilahun Yilma → Scientist
(38,2),  -- Mulat Demeke → Scientist (Economics)
(39,9),  -- Fikre Tolossa → Educator
(40,2),  -- Yohannes Haile-Selassie → Scientist

(41,2),  -- Rediet Abebe → Scientist (AI)
(42,7),  -- Betelhem Dessie → Engineer

(43,4),  -- Abiy Ahmed → Leader
(44,2),  -- Eleni Gabre-Madhin → Scientist
(45,7),  -- Dereje Agonafer → Engineer
(46,2),  -- Sossina Haile → Scientist
(47,2),  -- Dr. Brook Lakew → Scientist
(48,2)   -- Berhane Asfaw → Scientist
ON CONFLICT (hero_id, category_id) DO NOTHING;


INSERT INTO Sources (hero_id, source_title, source_link) VALUES
(1, 'Abebe Bikila Biography', 'https://en.wikipedia.org/wiki/Abebe_Bikila'),
(2, 'Tirunesh Dibaba Profile', 'https://en.wikipedia.org/wiki/Tirunesh_Dibaba'),
(3, 'Derartu Tulu Overview', 'https://en.wikipedia.org/wiki/Derartu_Tulu'),
(4, 'Haile Selassie Life', 'https://en.wikipedia.org/wiki/Haile_Selassie'),
(5, 'Tewodros II Historical Record', 'https://en.wikipedia.org/wiki/Tewodros_II'),
(6, 'Belay Zeleke Resistance', 'https://en.wikipedia.org/wiki/Belay_Zeleke'),
(7, 'Afework Tekle Works', 'https://en.wikipedia.org/wiki/Afework_Tekle'),
(8, 'Melaku Worede Achievements', 'https://en.wikipedia.org/wiki/Melaku_Worede'),
(9, 'Kitaw Ejigu NASA Contributions', 'https://en.wikipedia.org/wiki/Kitaw_Ejigu'),
(10, 'Bogaletch Gebre Biography', 'https://en.wikipedia.org/wiki/Bogaletch_Gebre'),
(11, 'Aklilu Lemma Contributions', 'https://en.wikipedia.org/wiki/Aklilu_Lemma'),
(12, 'Mamo Wolde Olympic Record', 'https://en.wikipedia.org/wiki/Mamo_Wolde'),
(13, 'Gebisa Ejeta Research', 'https://en.wikipedia.org/wiki/Gebisa_Ejeta'),
(14, 'Kenenisa Bekele Achievements', 'https://en.wikipedia.org/wiki/Kenenisa_Bekele'),
(15, 'Almaz Ayana Profile', 'https://en.wikipedia.org/wiki/Almaz_Ayana'),
(16, 'Yohannes IV History', 'https://en.wikipedia.org/wiki/Yohannes_IV'),
(17, 'Menelik II Biography', 'https://en.wikipedia.org/wiki/Menelik_II'),
(18, 'Empress Taytu Betul', 'https://en.wikipedia.org/wiki/Taytu_Betul'),
(19, 'Shewareged Gedle Profile', 'https://en.wikipedia.org/wiki/Shewareged_Gedle'),
(20, 'Empress Zewditu Biography', 'https://en.wikipedia.org/wiki/Zewditu'),
(21, 'Aklilu Habte-Wold History', 'https://en.wikipedia.org/wiki/Aklilu_Habte-Wold'),
(22, 'Lucy (Australopithecus) Research', 'https://en.wikipedia.org/wiki/Lucy_(Australopithecus)'),
(23, 'Tsehaytu Beraki Works', 'https://en.wikipedia.org/wiki/Tsehaytu_Beraki'),
(24, 'Haile Gebrselassie Achievements', 'https://en.wikipedia.org/wiki/Haile_Gebrselassie'),
(25, 'Liya Kebede Activism', 'https://en.wikipedia.org/wiki/Liya_Kebede'),
(26, 'Yirgalem Fisseha Art', 'https://en.wikipedia.org/wiki/Yirgalem_Fisseha'),
(27, 'Zeresenay Alemseged Discoveries', 'https://en.wikipedia.org/wiki/Zeresenay_Alemseged'),
(28, 'Emperor Lalibela History', 'https://en.wikipedia.org/wiki/Lalibela'),
(29, 'Mulatu Astatke Profile', 'https://en.wikipedia.org/wiki/Mulatu_Astatke'),
(30, 'Abel Tesfaye Biography', 'https://en.wikipedia.org/wiki/The_Weeknd'),
(31, 'Haddis Alemayehu Works', 'https://en.wikipedia.org/wiki/Haddis_Alemayehu'),
(32, 'Richard Pankhurst Biography', 'https://en.wikipedia.org/wiki/Richard_Pankhurst_(historian)'),
(33, 'Tsegaye Gabre-Medhin Biography', 'https://en.wikipedia.org/wiki/Tsegaye_Gabre-Medhin'),
(34, 'Mesfin Woldemariam Contributions', 'https://en.wikipedia.org/wiki/Mesfin_Woldemariam'),
(35, 'Bahru Zewde Biography', 'https://en.wikipedia.org/wiki/Bahru_Zewde'),
(36, 'Segenet Kelemu Profile', 'https://en.wikipedia.org/wiki/Segenet_Kelemu'),
(37, 'Tilahun Yilma Research', 'https://en.wikipedia.org/wiki/Tilahun_Yilma'),
(38, 'Mulat Demeke Economics Research', 'https://en.wikipedia.org/wiki/Mulat_Demeke'),
(39, 'Fikre Tolossa Works', 'https://en.wikipedia.org/wiki/Fikre_Tolossa'),
(40, 'Yohannes Haile-Selassie Research', 'https://en.wikipedia.org/wiki/Yohannes_Haile-Selassie'),
(41, 'Rediet Abebe AI Work', 'https://en.wikipedia.org/wiki/Rediet_Abebe'),
(42, 'Betelhem Dessie Tech Contributions', 'https://en.wikipedia.org/wiki/Betelhem_Dessie'),
(43, 'Abiy Ahmed Profile', 'https://en.wikipedia.org/wiki/Abiy_Ahmed'),
(44, 'Eleni Gabre-Madhin Work', 'https://en.wikipedia.org/wiki/Eleni_Gabre-Madhin'),
(45, 'Dereje Agonafer Contributions', 'https://en.wikipedia.org/wiki/Dereje_Agonafer'),
(46, 'Sossina Haile Research', 'https://en.wikipedia.org/wiki/Sossina_Haile'),
(47, 'Dr. Brook Lakew Profile', 'https://en.wikipedia.org/wiki/Brook_Lakew'),
(48, 'Berhane Asfaw Contributions', 'https://en.wikipedia.org/wiki/Berhane_Asfaw')
ON CONFLICT (hero_id, source_title) DO NOTHING;


-- DROP TABLE IF EXISTS Comments CASCADE;
-- DROP TABLE IF EXISTS HeroViews CASCADE;
-- DROP TABLE IF EXISTS Favorites CASCADE;
-- DROP TABLE IF EXISTS Sources CASCADE;
-- DROP TABLE IF EXISTS Achievements CASCADE;
-- DROP TABLE IF EXISTS HeroImages CASCADE;
-- DROP TABLE IF EXISTS HeroCategories CASCADE;
-- DROP TABLE IF EXISTS Heroes CASCADE;
-- DROP TABLE IF EXISTS Categories CASCADE;
-- DROP TABLE IF EXISTS Eras CASCADE;
-- DROP TABLE IF EXISTS Users CASCADE;

SELECT * FROM Users;
SELECT * FROM Eras;
SELECT * FROM Categories;
SELECT * FROM Heroes
LIMIT 20;
SELECT * FROM HeroCategories;
SELECT * FROM HeroImages;
SELECT * FROM Achievements;
SELECT * FROM Sources;
SELECT * FROM Favorites;
SELECT * FROM HeroViews;
SELECT * FROM Comments;
