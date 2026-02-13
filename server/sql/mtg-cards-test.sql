drop database if exists mtg_app_test;
create database mtg_app_test;
use mtg_app_test;

-- Create the tables and their relationships
-- First tables with no dependencies
create table `role` (
    role_id int primary key auto_increment,
    role_name varchar(50) not null
);

create table `card_type` (
    card_type_id int primary key auto_increment,
    card_type varchar(50)
);

create table `rarity` (
    rarity_id int primary key auto_increment,
    name varchar(50)
);

create table `card_oracle` (
    oracle_id char(36) primary key,
    `name` varchar(150) not null,
    mana_cost varchar(100),
    cmc tinyint unsigned default 0,
    card_type_id int not null default 9,
    oracle_text text,
    color_identity varchar(50),
    layout varchar(50),
    constraint fk_card_oracle_card_type_id
        foreign key (card_type_id)
        references `card_type`(card_type_id)
);

create table `user` (
	user_id int primary key auto_increment,
	username varchar(50) not null unique,
    email varchar(100) not null unique,
    password_hash_char varchar(255) not null,
    is_restricted tinyint(1) default 0,
    created_at timestamp default current_timestamp
);



-- Tables with dependencies

create table `user_role` (
    user_id int not null,
    role_id int not null,

    primary key (user_id, role_id),

    constraint fk_user_role_user_id
    		foreign key (user_id)
            references `user`(user_id),
    constraint fk_user_role_role_id
            foreign key (role_id)
            references `role`(role_id)
);

create table collection (
	collection_id int primary key auto_increment,
    user_id int not null,
    collection_name varchar(200) default 'Main Collection',

    constraint fk_collection_user_id
		foreign key (user_id)
        references `user`(user_id)
);

create table `card_printing` (
    printing_id char(36) primary key,
    oracle_id char(36) not null,
    set_code varchar(30),
    set_name varchar(100),
    rarity_id int not null default 2,
    collector_number varchar(30),
    image_uri varchar(500) not null,
    flavor_text text,

    constraint fk_card_printing_oracle_id
        foreign key (oracle_id)
        references `card_oracle`(oracle_id),
    constraint fk_card_printing_rarity_id
        foreign key (rarity_id)
        references `rarity`(rarity_id)
);

create table collected_card (
	collected_card_id int primary key auto_increment,
    collection_id int not null,
    printing_id char(36),
    quantity int not null default 1,
    is_foil boolean default false,
    card_condition ENUM('M', 'NM', 'LP', 'MP', 'HP', 'D'),
    acquired_date date,

    constraint fk_collected_card_collection_id
		foreign key (collection_id)
        references collection(collection_id),
	constraint fk_collected_card_printing_id
		foreign key (printing_id)
        references card_printing (printing_id),

    unique key uk_collection_printing_foil (collection_id, printing_id, is_foil)
);


insert into card_type (card_type_id, card_type)
values
(1, 'Artifact'),
(2, 'Creature'),
(3, 'Enchantment'),
(4, 'Land'),
(5, 'Instant'),
(6, 'Planeswalker'),
(7, 'Sorcery'),
(8, 'Battle'),
(9, 'Unknown');


insert into rarity (rarity_id, name)
values
(1, 'Common'),
(2, 'Uncommon'),
(3, 'Rare'),
(4, 'Mythic'),
(5, 'Special'),
(6, 'Bonus');

insert into role (role_id, role_name)
values
(1, 'USER'),
(2, 'ADMIN'),
(3, 'SUPER_ADMIN');

-- Set up testing
delimiter //
create procedure set_known_good_state()
begin
	    delete from collected_card;
        alter table collected_card auto_increment = 1;
        delete from collection;
        alter table collection auto_increment = 1;
        delete from collected_card;
        alter table collected_card auto_increment = 1;
        delete from card_printing;
        alter table card_printing auto_increment = 1;
        delete from card_oracle;
        alter table card_oracle auto_increment = 1;

        delete from user_role;
        alter table user_role auto_increment = 1;
        delete from `user`;
        alter table `user` auto_increment = 1;


    insert into `user` (`user_id`,`username`,`email`,`password_hash_char`,`is_restricted`,`created_at`) values
        (1,'george','george@mail.com','$2a$10$jyIwwSytGOU43X7PPe8BOevjtbOT3V2naTPUbiKsD0kK6Z2x74l/e',0, now()),
        (2,'user','user@mail.com','$2a$10$CVNkWJ5z/OBpqQ0NncBIueF7qDKFP3e5E573lEMpIIyO08eaLDz4y',0, now()),
        (3,'admin','admin@mail.com','$2a$10$MmuaTPFC39Xmod.Xg2CbfeprpWU6Msd.2sw3IrfCYVqtfc94frioe',0, now()),
        (4,'mike', 'collector@mtg.com', '$2a$10$8.UnVuG9HHgffUDAlk8Kn.2ndfJGX9VCV3.9.e89u2vS.V0O.7m06', 0, now());

    insert into user_role (user_id, role_id) values
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 1);

    insert into collection(collection_id, user_id, collection_name)
    values
    (1, 3, 'My great collection'),
    (2, 1,'test collection');

    insert into card_oracle (oracle_id, name, mana_cost, cmc, card_type_id, oracle_text, color_identity, layout)
    values
    ('f2da35d5-c13f-4e01-a083-d9d83935ed1f', 'Lightning Bolt', '{R}', 1.0, 1, 'Lightning Bolt deals 3 damage to any target.', 'R', 'normal'),
    ('698380e2-63b1-4fca-8640-59f7d4323e0d', 'Black Lotus', '{0}', 0.0, 2, '{T}, Sacrifice Black Lotus: Add three mana of any one color.', '', 'normal');


    insert into card_printing (printing_id, oracle_id, set_code, set_name, rarity_id, collector_number, image_uri, flavor_text)
    values
    ('8607a3c3-6b79-4934-934d-045373a6e9a3', 'f2da35d5-c13f-4e01-a083-d9d83935ed1f', 'lea', 'Limited Edition Alpha', 1, '588',
    '{"normal": "https://cards.scryfall.io/normal/front/8/6/8607a3c3-6b79-4934-934d-045373a6e9a3.jpg"}', "Flavor_Text"),
    ('96053f3e-862d-451e-84b2-06927961239c', 'f2da35d5-c13f-4e01-a083-d9d83935ed1f', 'sld', 'Secret Lair Drop', 2, '999',
    '{"normal": "https://cards.scryfall.io/normal/front/9/6/96053f3e-862d-451e-84b2-06927961239c.jpg"}', "Flavor_Text"),
    ('bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd', '698380e2-63b1-4fca-8640-59f7d4323e0d', 'lea', 'Limited Edition Alpha', 3, '230',
    '{"normal": "https://cards.scryfall.io/normal/front/b/d/bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd.jpg"}', "Flavor_Text");
    
    insert into collected_card(collected_card_id, collection_id, printing_id, quantity, is_foil, card_condition, acquired_date)
    values
    (1, 2, '96053f3e-862d-451e-84b2-06927961239c', 1, false, 'NM', now()),
    (2, 2, '8607a3c3-6b79-4934-934d-045373a6e9a3', 2, false, 'LP', now()),
    (3, 1, 'bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd', 1, false, 'LP', now());

end //
delimiter ;

--SELECT
--    u.username,
--    oc.name AS card_name,
--    cp.set_code,
--    ci.quantity,
--    ci.card_condition,
--    (cp.price_usd * ci.quantity) AS total_value
--FROM users u
--JOIN collections c ON u.user_id = c.user_id
--JOIN collection_items ci ON c.collection_id = ci.collection_id
--JOIN card_printings cp ON ci.scryfall_id = cp.scryfall_id
--JOIN oracle_cards oc ON cp.oracle_id = oc.oracle_id;