-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 02, 2020 at 11:02 AM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT = @@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS = @@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION = @@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `airline`
--

DELIMITER $$
--
-- Procedures
--
CREATE
    DEFINER = `root`@`localhost` PROCEDURE `above18_passengers`(IN `flight_id_in` INT)
BEGIN

    set @last = (SELECT last_flight_schedule_id(flight_id_in));

    SELECT firstName                      as 'First Name',
           secondName                        'Last Name',
           email                          as 'Email',
           CONVERT(passport_id, char(30)) as 'Passport ID'
    from user
             NATURAL JOIN book
    WHERE book.schedule_id = @last
      and TIMESTAMPDIFF(YEAR, BirthDay, CURDATE()) >= 18;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `add_payment`(IN `scheduleid` INT(10), IN `seatid` INT(10),
                                                         IN `userid` INT(10), IN `today` VARCHAR(100),
                                                         IN `first_name1` VARCHAR(100), IN `last_name1` VARCHAR(100),
                                                         IN `birthday1` DATE, IN `passport_id1` VARCHAR(100),
                                                         IN `book_id1` INT)
BEGIN
    start transaction;
    set @seat_price = (SELECT `price`
                       FROM `seat_details_according_to_schedule`
                       where seat_details_according_to_schedule.schedule_id = scheduleid
                         and seat_details_according_to_schedule.seat_id = seatid);
    set @discount = (SELECT percentage
                     FROM `discount_percentage`
                              LEFT join user on discount_percentage.type = user.user_type
                     WHERE user.user_id = userid);
    IF @discount IS NOT null THEN
        set @seat_price = ((100 - @discount) * @seat_price) / 100;
    end if;
    INSERT INTO `book` (`date`, `schedule_id`, `seat_id`, `user_id`, `payment`, id)
    VALUES (today, scheduleid, seatid, userid, @seat_price, book_id1);

    insert into passenger(first_name, last_name, birthday, passport_id, book_id)
    values (first_name1, last_name1, birthday1, passport_id1, book_id1);
    commit;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `add_user`(IN `first_name` VARCHAR(200), IN `second_name` VARCHAR(200),
                                                      IN `email` VARCHAR(200), IN `nic` VARCHAR(200),
                                                      IN `passport_id` VARCHAR(200), IN `birthday` DATE,
                                                      IN `username` VARCHAR(200), IN `password` VARCHAR(200),
                                                      IN `id` INT) MODIFIES SQL DATA
BEGIN
    START TRANSACTION;
    INSERT INTO user(user_id, firstName, secondName, email, nic, passport_id, BirthDay, number_of_bookings, user_type)

    VALUES (id, first_name, second_name, email, nic, passport_id, birthday, 0, '');
    SET FOREIGN_KEY_CHECKS = 0;
    INSERT INTO registered_user(user_id, username, PASSWORD) VALUES (id, username, password);
    SET FOREIGN_KEY_CHECKS = 1;
    COMMIT;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `age_compare`(`id` INT(10))
BEGIN
    SELECT user_id, age_above_18(book.user_id) as IS_ABOVE_18 from book WHERE book.id = id;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `below18_passengers`(IN `flight_id_in` INT)
BEGIN

    set @last = (SELECT last_flight_schedule_id(flight_id_in));

    SELECT firstName                      as 'First Name',
           secondName                        'Last Name',
           email                          as 'Email',
           CONVERT(passport_id, char(30)) as 'Passport ID'
    from user
             NATURAL JOIN book
    WHERE book.schedule_id = @last
      and TIMESTAMPDIFF(YEAR, BirthDay, CURDATE()) <= 18;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `get_above_18`(IN `flight_id_in` INT) NO SQL
BEGIN

    set @last = (SELECT last_flight_schedule_id(flight_id_in));

    SELECT first_name as 'First Name', last_name 'Last Name', CONVERT(passport_id, char(30)) as 'Passport ID'
    from passenger
    WHERE book_id in (SELECT id from book where schedule_id = @last)
      and TIMESTAMPDIFF(YEAR, birthday, CURDATE()) >= 18;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `get_all_schedules`()
begin
    SELECT schedule.schedule_id,
           schedule.date,
           schedule.flight_id,
           route.route_id,
           ori.name                  as origin,
           des.name                  as destination,
           airplane.airplane_id      as airplane_id,
           airplane_model.model_name as model_name,
           airplane_model.model_id   as model_id,
           schedule.dep_time,
           schedule.arival_time      as arrival_time,
           gate.name                 as gate_name
    from schedule
             inner join flight on schedule.flight_id = flight.flight_id
             inner join airplane on airplane.airplane_id = flight.airplane_id
             inner join airplane_model on airplane_model.model_id = airplane.model_id
             inner join route on route.route_id = flight.route_id
             inner join gate on schedule.gate_id = gate.gate_id
             inner join airport ori on ori.airport_id = route.origin
             inner join airport des on des.airport_id = route.destination;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `get_below_18`(IN `flight_id_in` INT) NO SQL
BEGIN

    set @last = (SELECT last_flight_schedule_id(flight_id_in));

    SELECT first_name as 'First Name', last_name 'Last Name', CONVERT(passport_id, char(30)) as 'Passport ID'
    from passenger
    WHERE book_id in (SELECT id from book where schedule_id = @last)
      and TIMESTAMPDIFF(YEAR, birthday, CURDATE()) <= 18;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `get_free_seats`(IN `model_id` VARCHAR(200), IN `flight_id` VARCHAR(200))
    READS SQL DATA
BEGIN
    select *
    from schedule
             inner join flight on schedule.flight_id = flight.flight_id
             inner join seat_price on flight.flight_id = seat_price.flight_id
             inner join seat on seat_price.seat_id = seat.seat_id
    where seat.seat_id not in (select book.seat_id from book)
      and seat.model_id = model_id
      and flight.flight_id = flight_id;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `get_gate_id_for_given_flight_id`(IN `flight_id_in` INT) NO SQL
BEGIN

    set @route_id = (SELECT route_id from flight WHERE flight_id = flight_id_in LIMIT 1);
    set @origin = (SELECT origin from route WHERE route_id = @route_id limit 1);
    SELECT gate_id from gate where airport_id = @origin ORDER BY gate_id DESC;

END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `get_past_flights`(IN `origin_name` VARCHAR(50), IN `destination_name` VARCHAR(50))
BEGIN
    set @origin_id = (SELECT airport_id from airport WHERE name = origin_name LIMIT 1);
    set @destination_id = (SELECT airport_id from airport WHERE name = destination_name LIMIT 1);
    set @route_id = (SELECT route_id from route WHERE origin = @origin_id and destination = @destination_id LIMIT 1);
    set @flight_id = (SELECT flight_id from flight where route_id = @route_id);
    SELECT * from schedule WHERE flight_id = @flight_id;
END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `get_schedules_filtered`(IN `origin` VARCHAR(3), IN `destination` VARCHAR(3),
                                                                    IN `from_date` DATE, IN `to_date` DATE)
    READS SQL DATA
BEGIN
    SELECT schedule.schedule_id,
           schedule.date,
           schedule.flight_id,
           route.route_id,
           ori.name                  as origin,
           des.name                  as destination,
           airplane.airplane_id      as airplane_id,
           airplane_model.model_name as model_name,
           airplane_model.model_id   as model_id,
           schedule.dep_time,
           schedule.arival_time      as arrival_time,
           gate.name                 as gate_name
    from schedule
             inner join flight on schedule.flight_id = flight.flight_id
             inner join airplane on airplane.airplane_id = flight.airplane_id
             inner join airplane_model on airplane_model.model_id = airplane.model_id
             inner join route on route.route_id = flight.route_id
             inner join gate on schedule.gate_id = gate.gate_id
             inner join airport ori on ori.airport_id = route.origin
             inner join airport des on des.airport_id = route.destination
    where des.code = destination
      and ori.code = origin
      and (date between from_date and to_date);

end$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `get_seat_id_for_given_schedule_id`(IN `schedule_id_in` INT) NO SQL
BEGIN

    set @flight_id = (SELECT flight_id from schedule WHERE schedule_id = schedule_id_in LIMIT 1);
    set @airplane_id = (SELECT airplane_id from flight WHERE flight_id = @flight_id limit 1);
    set @model_id = (SELECT model_id from airplane WHERE airplane_id = @airplane_id);

    SELECT seat_id from seat where model_id = @model_id;

END$$

CREATE
    DEFINER = `root`@`localhost` PROCEDURE `update_user`(IN `first_name` VARCHAR(200), IN `second_name` VARCHAR(200),
                                                         IN `email1` VARCHAR(200), IN `nic1` VARCHAR(200),
                                                         IN `passport_id1` VARCHAR(200), IN `birthday1` DATE,
                                                         IN `username1` VARCHAR(200), IN `password1` VARCHAR(200),
                                                         IN `id` INT)
BEGIN
    START TRANSACTION;
    SET FOREIGN_KEY_CHECKS = 0;
    update user
    set firstName  =first_name,
        secondName =second_name,
        email=email1,
        nic=nic1,
        passport_id=passport_id1,
        BirthDay=birthday1
    where user_id = id;
    INSERT INTO registered_user(user_id, username, PASSWORD) VALUES (id, username, password);
    update registered_user
    set username =username1,
        password=password1
    where user_id = id;
    SET FOREIGN_KEY_CHECKS = 1;
    COMMIT;
END$$

--
-- Functions
--
CREATE
    DEFINER = `root`@`localhost` FUNCTION `age_above_18`(`user_id` INT(10)) RETURNS TINYINT(1)
BEGIN
    DECLARE siri BOOLEAN;
    DECLARE AGE0 INT(10);
    SELECT age
    INTO AGE0
    from user
    WHERE user.user_id = user_id;
    IF AGE0 < 18 THEN
        set siri = FALSE;
    ELSE
        set siri = TRUE;
    END IF;

    RETURN siri;
END$$

CREATE
    DEFINER = `root`@`localhost` FUNCTION `frequent_members`() RETURNS INT(11)
BEGIN
    DECLARE ret int;
    SELECT COUNT(user_id) into ret FROM discount WHERE trips > 0;
    RETURN ret;
END$$

CREATE
    DEFINER = `root`@`localhost` FUNCTION `getlocation`(`parent_id` INT(10)) RETURNS VARCHAR(200) CHARSET latin1
BEGIN
    DECLARE id INT(10);
    declare loc_name varchar(20);
    DECLARE full_name varchar(200);
    set full_name = '';

    SELECT location.child_id, location_name.name
    FROM location
             NATURAL JOIN location_name
    WHERE location_id = parent_id
    INTO id,loc_name;
    SET full_name = concat(loc_name, full_name);

    while (id is not null)
        DO
            SELECT location.child_id, location_name.name
            FROM location
                     NATURAL JOIN location_name
            WHERE location_id = id
            INTO id,loc_name;
            set loc_name = concat(loc_name, ',');
            SET full_name = concat(loc_name, full_name);
        end while;


    RETURN full_name;
END$$

CREATE
    DEFINER = `root`@`localhost` FUNCTION `getlocation2`(`child_id` INT) RETURNS VARCHAR(200) CHARSET latin1
BEGIN
    DECLARE id INT(10);
    declare loc_name varchar(20);
    DECLARE full_name varchar(200);
    set full_name = '';

    SELECT location.parent_id, location_name.name
    FROM location
             NATURAL JOIN location_name
    WHERE location_id = child_id
    INTO id,loc_name;
    SET full_name = concat(loc_name, full_name);

    while (id is not null)
        DO
            SELECT location.parent_id, location_name.name
            FROM location
                     NATURAL JOIN location_name
            WHERE location_id = id
            INTO id,loc_name;
            set loc_name = concat(',', loc_name);
            SET full_name = concat(full_name, loc_name);
        end while;


    RETURN full_name;

END$$

CREATE
    DEFINER = `root`@`localhost` FUNCTION `get_revenue`(`model_name_in` VARCHAR(30)) RETURNS DOUBLE NO SQL
BEGIN
    DECLARE output double;
    set @model_id = (SELECT model_id from airplane_model where model_name = model_name_in);
    set @airplane_id = (SELECT airplane_id FROM airplane where model_id = @model_id);
    set @flight_id = (SELECT flight_id from flight where airplane_id = @airplane_id);
    SELECT sum(payment)
    INTO output
    from book
    where schedule_id in (SELECT schedule_id from schedule where flight_id = @flight_id);
    RETURN output;
END$$

CREATE
    DEFINER = `root`@`localhost` FUNCTION `get_Total_price_with_discount`(`user_id` INT(10), `seat_id` INT(10)) RETURNS FLOAT(10, 2)
BEGIN
    DECLARE total_price float(10, 2);
    DECLARE seat_price float(10, 2);
    DECLARE num_trips INT(10);

    SELECT `trips` FROM `discount` WHERE discount.user_id = user_id INTO num_trips;
    SELECT `price` FROM `seat_price` WHERE seat_price.seat_id = seat_id INTO seat_price;
    IF num_trips > 9 THEN
        set seat_price = seat_price - seat_price * 0.09;
    ELSEIF num_trips > 4 THEN
        set seat_price = seat_price - seat_price * 0.05;
    END IF;

    RETURN seat_price;
END$$

CREATE
    DEFINER = `root`@`localhost` FUNCTION `gold_members`() RETURNS INT(11)
BEGIN
    DECLARE ret int;
    SELECT COUNT(user_id) into ret FROM discount WHERE trips > 1;
    RETURN ret;
END$$

CREATE
    DEFINER = `root`@`localhost` FUNCTION `last_flight_schedule_id`(`flight_id_in` INT(10)) RETURNS INT(11)
BEGIN
    set @schedule_id_out1 =
            (SELECT schedule_id from schedule WHERE flight_id = flight_id_in ORDER BY dep_time DESC LIMIT 1);
    RETURN @schedule_id_out1;
END$$

CREATE
    DEFINER = `root`@`localhost` FUNCTION `no_of_passengers_from_origin`(`airport_code` CHAR(3), `from_date` DATE, `to_date` DATE) RETURNS INT(11)
BEGIN
    DECLARE output int;
    SELECT count(book.id)
    into output
    from airport
             INNER JOIN route ON airport.airport_id = route.origin
             INNER JOIN flight USING (route_id)
             INNER JOIN airline.schedule USING (flight_id)
             INNER JOIN book USING (schedule_id)
    WHERE code = airport_code
      and schedule.date < to_date
      and schedule.date > from_date;
    RETURN output;
END$$

CREATE
    DEFINER = `root`@`localhost` FUNCTION `no_of_passengers_to_dest`(`airport_code` CHAR(3), `from_date` DATE, `to_date` DATE) RETURNS INT(11)
BEGIN
    DECLARE output int;
    SELECT count(book.id)
    into output
    from airport
             INNER JOIN route ON airport.airport_id = route.destination
             INNER JOIN flight USING (route_id)
             INNER JOIN schedule USING (flight_id)
             INNER JOIN book USING (schedule_id)
    WHERE airport.code = airport_code
      and schedule.date < to_date
      and schedule.date > from_date;
    RETURN output;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin`
(
    `admin_id` int(11)       NOT NULL,
    `email`    varchar(200)  NOT NULL,
    `password` varchar(1000) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`admin_id`, `email`, `password`)
VALUES (1, 'admin@gmail.com', '$2a$10$rp/KlmLUOZ2yNCt5SRTyJer9vg.I3i9y8FjX.Sg7Oi0LEAvGShQZ2');

-- --------------------------------------------------------

--
-- Table structure for table `airplane`
--

CREATE TABLE `airplane`
(
    `airplane_id` int(10)     NOT NULL,
    `model_id`    varchar(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `airplane`
--

INSERT INTO `airplane` (`airplane_id`, `model_id`)
VALUES (1, '0001'),
       (2, '0002'),
       (3, '0003'),
       (4, '0004'),
       (5, '0005'),
       (6, '0006'),
       (7, '0007'),
       (8, '0008'),
       (9, '0009'),
       (10, '0010'),
       (11, '0011');

-- --------------------------------------------------------

--
-- Table structure for table `airplane_model`
--

CREATE TABLE `airplane_model`
(
    `model_id`   varchar(10) NOT NULL,
    `model_name` varchar(30) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `airplane_model`
--

INSERT INTO `airplane_model` (`model_id`, `model_name`)
VALUES ('0001', 'AirBus A220'),
       ('0002', 'AirBus A319'),
       ('0003', 'AirBus A320'),
       ('0004', 'AirBus A321'),
       ('0005', 'AirBus A330'),
       ('0006', 'AirBus A350 XWB'),
       ('0007', 'AirBus A380'),
       ('0008', 'Antonov An-148'),
       ('0009', 'Antonov An-158'),
       ('0010', 'Boeing 737'),
       ('0011', 'Boeing 747'),
       ('0012', 'Boeing 767'),
       ('0013', 'Boeing 777'),
       ('0014', 'Boeing 787 Dreamliner'),
       ('0015', 'Comac C919'),
       ('0017', 'Embraer E-170'),
       ('0016', 'Embraer ERJ 135'),
       ('0018', 'Ilyushin Il-96'),
       ('0019', 'Irkut MC-21'),
       ('0020', 'Mitsubishi Regional Jet');

--
-- Triggers `airplane_model`
--
DELIMITER $$
CREATE TRIGGER `checkairplanemodel`
    BEFORE INSERT
    ON `airplane_model`
    FOR EACH ROW
BEGIN
    DECLARE id1 int(10);

    SELECT `model_id`
    INTO id1
    FROM `airplane_model`
    WHERE airplane_model.model_name = NEW.model_name
      and airplane_model.model_id = NEW.model_id
    LIMIT 1;
    IF id1 is not NULL THEN
        SIGNAL SQLSTATE '45000';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `airport`
--

CREATE TABLE `airport`
(
    `airport_id`      int(10)     NOT NULL,
    `location_id`     int(10)     NOT NULL,
    `name`            varchar(50) NOT NULL,
    `code`            char(3)     NOT NULL,
    `timezone_offset` varchar(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `airport`
--

INSERT INTO `airport` (`airport_id`, `location_id`, `name`, `code`, `timezone_offset`)
VALUES (1, 5, 'Bandaranaike International Airport', 'CMB', '+05:30'),
       (2, 3, 'Mattala Rajapaksa Hambantota Airport', 'HRI', '+05:30'),
       (3, 10, 'Hartsfield–Jackson Atlanta International Airport', 'ATL', '+04'),
       (4, 13, 'Beijing Capital International Airport', 'PEK', '+08'),
       (5, 16, 'Tokyo Haneda Airport', 'HND', '+09'),
       (6, 19, 'Dubai International Airport', 'DXB', '+03');

--
-- Triggers `airport`
--
DELIMITER $$
CREATE TRIGGER `checkairport`
    BEFORE INSERT
    ON `airport`
    FOR EACH ROW
BEGIN
    DECLARE id1 int(10);

    SELECT `airport_id`
    INTO id1
    FROM `airport`
    WHERE airport.location_id = NEW.location_id
      and airport.code = NEW.code
    LIMIT 1;
    IF id1 is not NULL THEN
        SIGNAL SQLSTATE '45000';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `book`
--

CREATE TABLE `book`
(
    `id`          int(10)   NOT NULL,
    `date`        timestamp NOT NULL DEFAULT current_timestamp(),
    `schedule_id` int(10)   NOT NULL,
    `seat_id`     int(10)   NOT NULL,
    `user_id`     int(10)   NOT NULL,
    `payment`     double             DEFAULT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `book`
--

INSERT INTO `book` (`id`, `date`, `schedule_id`, `seat_id`, `user_id`, `payment`)
VALUES (13, '2019-10-31 19:17:22', 1, 75, 1, 170000),
       (14, '2019-11-02 18:30:00', 1, 104, 203018270, 160900),
       (15, '2019-12-01 18:30:00', 1, 105, 3, 123000),
       (16, '2019-11-02 18:30:00', 1, 83, 3, 132000),
       (17, '2019-11-19 01:30:00', 1, 76, 4, 180000),
       (18, '2019-11-11 18:30:00', 1, 107, 5, 230000),
       (19, '2019-10-05 18:30:00', 1, 90, 5, 124000),
       (20, '2019-11-03 18:30:00', 1, 94, 203018270, 130000),
       (21, '2019-11-02 18:30:00', 2, 105, 8, 190800),
       (22, '2019-11-03 18:30:00', 2, 104, 10, 78000),
       (23, '2019-11-13 18:30:00', 2, 106, 13, 123000),
       (24, '2019-11-29 18:30:00', 2, 107, 6, 130000),
       (25, '2019-11-30 18:30:00', 2, 99, 2, 167000),
       (26, '2019-11-29 18:30:00', 2, 100, 203018270, 156000),
       (27, '2019-12-31 18:30:00', 1, 109, 203018270, 118300),
       (17939109, '2020-01-01 18:30:00', 1, 79, 203018270, 112294),
       (48724759, '2019-12-31 18:30:00', 1, 81, 1, 180500),
       (98505715, '2020-01-01 18:30:00', 1, 106, 203018270, 117230);

--
-- Triggers `book`
--
DELIMITER $$
CREATE TRIGGER `check_date_for_booking`
    BEFORE INSERT
    ON `book`
    FOR EACH ROW
BEGIN
    set @id1 = NEW.schedule_id;
    set @id0 = NEW.date;
    set @date = (select date from schedule where schedule_id = @id1);

    set @yes = (SELECT IF(@id0 > @date, TRUE, FALSE));
    IF @yes THEN
        SIGNAL SQLSTATE '45000';

    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_seats`
    BEFORE INSERT
    ON `book`
    FOR EACH ROW
BEGIN
    set @id1 = NEW.schedule_id;
    set @id0 = NEW.seat_id;
    set @flight_id = (SELECT flight_id from schedule WHERE schedule_id = @id1 LIMIT 1);
    set @airplane_id = (SELECT airplane_id from flight WHERE flight_id = @flight_id limit 1);
    set @model_id = (SELECT model_id from airplane WHERE airplane_id = @airplane_id);
    set @yes = (SELECT IF(@id0 not in (SELECT seat_id from seat where model_id = @model_id), TRUE, FALSE));
    IF @yes THEN
        SIGNAL SQLSTATE '45000';

    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `isbooked`
    BEFORE INSERT
    ON `book`
    FOR EACH ROW
BEGIN
    DECLARE id1 int(10);

    SELECT `id` INTO id1 FROM `book` WHERE book.seat_id = NEW.seat_id and book.schedule_id = NEW.schedule_id LIMIT 1;
    IF id1 is not NULL THEN
        SIGNAL SQLSTATE '45000';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `set_type_of_user`
    AFTER INSERT
    ON `book`
    FOR EACH ROW
BEGIN
    SET @id = NEW.user_id;
    SET @cnt = (select count(user_id) from book where user_id = @id LIMIT 1);
    update user set number_of_bookings=@cnt where user_id = @id;
    set @gold = (select threshold from discount_percentage where type = 'Gold');
    set @frequent = (select threshold from discount_percentage where type = 'Frequent');

    IF @cnt >= @gold THEN
        update user set user_type='Gold' where user_id = @id;
    ELSEIF @cnt >= @frequent THEN
        update user set user_type='Frequent' where user_id = @id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `book_details`
-- (See below for the actual view)
--
CREATE TABLE `book_details`
(
    `id`             int(10),
    `schedule_id`    int(10),
    `user_id`        int(10),
    `date`           timestamp,
    `scheduled_date` date,
    `origin`         varchar(50),
    `destination`    varchar(50),
    `airplane_model` varchar(30),
    `dep_time`       time,
    `arival_time`    time,
    `gate_name`      varchar(50),
    `seat_name`      varchar(10),
    `seat_class`     varchar(10)
);

-- --------------------------------------------------------

--
-- Table structure for table `cabin_crew`
--

CREATE TABLE `cabin_crew`
(
    `staff_id` int(11)     NOT NULL,
    `nic`      varchar(10) NOT NULL,
    `type`     varchar(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

-- --------------------------------------------------------

--
-- Stand-in structure for view `discount`
-- (See below for the actual view)
--
CREATE TABLE `discount`
(
    `user_id` int(10),
    `trips`   bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `discount_percentage`
--

CREATE TABLE `discount_percentage`
(
    `type`       varchar(20) NOT NULL,
    `percentage` int(2)      NOT NULL,
    `threshold`  int(11)     NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `discount_percentage`
--

INSERT INTO `discount_percentage` (`type`, `percentage`, `threshold`)
VALUES ('Frequent', 5, 2),
       ('Gold', 9, 5);

-- --------------------------------------------------------

--
-- Table structure for table `flight`
--

CREATE TABLE `flight`
(
    `flight_id`   int(10) NOT NULL,
    `route_id`    int(10) NOT NULL,
    `airplane_id` int(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `flight`
--

INSERT INTO `flight` (`flight_id`, `route_id`, `airplane_id`)
VALUES (1, 1, 1),
       (2, 2, 5),
       (3, 3, 4),
       (4, 4, 2),
       (5, 5, 8),
       (6, 6, 7);

--
-- Triggers `flight`
--
DELIMITER $$
CREATE TRIGGER `checkflight`
    BEFORE INSERT
    ON `flight`
    FOR EACH ROW
BEGIN
    DECLARE id1 int(10);

    SELECT `flight_id`
    INTO id1
    FROM `flight`
    WHERE flight.route_id = NEW.route_id
      and flight.airplane_id = NEW.airplane_id
    LIMIT 1;
    IF id1 is not NULL THEN
        SIGNAL SQLSTATE '45000';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `flight_details`
-- (See below for the actual view)
--
CREATE TABLE `flight_details`
(
    `flight_id`   int(10),
    `origin`      varchar(50),
    `destination` varchar(50),
    `model_name`  varchar(30)
);

-- --------------------------------------------------------

--
-- Table structure for table `gate`
--

CREATE TABLE `gate`
(
    `gate_id`    int(10)     NOT NULL,
    `airport_id` int(10)     NOT NULL,
    `name`       varchar(50) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `gate`
--

INSERT INTO `gate` (`gate_id`, `airport_id`, `name`)
VALUES (2, 1, 'A22'),
       (6, 1, 'C56'),
       (1, 1, 'D34'),
       (3, 1, 'S32'),
       (4, 1, 'X23'),
       (5, 1, 'X45'),
       (11, 2, 'A22'),
       (14, 2, 'C56'),
       (10, 2, 'D34'),
       (12, 2, 'S32'),
       (15, 2, 'X23'),
       (13, 2, 'X45'),
       (17, 3, 'A22'),
       (20, 3, 'C56'),
       (16, 3, 'D34'),
       (18, 3, 'S32'),
       (21, 3, 'X23'),
       (19, 3, 'X45'),
       (23, 4, 'A22'),
       (26, 4, 'C56'),
       (22, 4, 'D34'),
       (24, 4, 'S32'),
       (27, 4, 'X23'),
       (25, 4, 'X45'),
       (29, 5, 'A22'),
       (32, 5, 'C56'),
       (28, 5, 'D34'),
       (30, 5, 'S32'),
       (33, 5, 'X23'),
       (31, 5, 'X45'),
       (35, 6, 'A22'),
       (38, 6, 'C56'),
       (34, 6, 'D34'),
       (36, 6, 'S32'),
       (39, 6, 'X23'),
       (37, 6, 'X45');

--
-- Triggers `gate`
--
DELIMITER $$
CREATE TRIGGER `checkgate`
    BEFORE INSERT
    ON `gate`
    FOR EACH ROW
BEGIN
    DECLARE id1 int(10);

    SELECT `gate_id` INTO id1 FROM `gate` WHERE gate.airport_id = NEW.airport_id and gate.name = NEW.name LIMIT 1;
    IF id1 is not NULL THEN
        SIGNAL SQLSTATE '45000';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `guest_user`
--

CREATE TABLE `guest_user`
(
    `user_id` int(11) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `guest_user`
--

INSERT INTO `guest_user` (`user_id`)
VALUES (1),
       (2),
       (3),
       (4),
       (5),
       (6),
       (7),
       (8);

-- --------------------------------------------------------

--
-- Table structure for table `location`
--

CREATE TABLE `location`
(
    `location_id` int(10) NOT NULL,
    `child_id`    int(10) DEFAULT NULL,
    `parent_id`   int(10) DEFAULT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `location`
--

INSERT INTO `location` (`location_id`, `child_id`, `parent_id`)
VALUES (1, 2, NULL),
       (1, 4, NULL),
       (2, 3, 1),
       (3, NULL, 2),
       (4, 5, 1),
       (5, NULL, 4),
       (6, NULL, 7),
       (7, NULL, 6),
       (8, 9, NULL),
       (9, 10, 8),
       (10, NULL, 9),
       (11, 12, NULL),
       (12, 13, 11),
       (13, NULL, 12),
       (14, 15, NULL),
       (15, 16, 14),
       (16, NULL, 15),
       (17, 18, NULL),
       (18, 19, 17),
       (19, NULL, 18);

-- --------------------------------------------------------

--
-- Table structure for table `location_name`
--

CREATE TABLE `location_name`
(
    `id`   int(10)     NOT NULL,
    `name` varchar(20) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `location_name`
--

INSERT INTO `location_name` (`id`, `name`)
VALUES (1, 'Sr Lanka'),
       (2, 'Hambanthota'),
       (3, 'Maththala'),
       (4, 'Colombo'),
       (5, 'Katunayake'),
       (6, 'Alexandria'),
       (7, 'Egypt'),
       (8, 'United States'),
       (9, 'Georgia'),
       (10, 'Atlanta'),
       (11, 'China'),
       (12, 'Beijing'),
       (13, 'Chaoyang-Shunyi'),
       (14, 'Japan'),
       (15, 'Tokyo'),
       (16, 'Ota'),
       (17, 'United Arab Emirates'),
       (18, 'Dubai'),
       (19, 'Garhoud');

-- --------------------------------------------------------

--
-- Table structure for table `passenger`
--

CREATE TABLE `passenger`
(
    `id`          int(11)     NOT NULL,
    `first_name`  varchar(30) NOT NULL,
    `last_name`   varchar(30) NOT NULL,
    `birthday`    date        NOT NULL,
    `passport_id` varchar(50) NOT NULL,
    `book_id`     int(10)     NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

--
-- Dumping data for table `passenger`
--

INSERT INTO `passenger` (`id`, `first_name`, `last_name`, `birthday`, `passport_id`, `book_id`)
VALUES (1, 'shashimal', 'senarath', '1997-01-05', '454626233B', 22),
       (2, 'string', 'string', '2005-08-07', 'string', 48724759),
       (4, 'Jasda', 'asdasd', '1997-09-03', 'sgassjdghg', 17939109);

-- --------------------------------------------------------

--
-- Table structure for table `pilot`
--

CREATE TABLE `pilot`
(
    `staff_id`   int(11)     NOT NULL,
    `licence_id` varchar(10) NOT NULL,
    `pilot_code` varchar(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

-- --------------------------------------------------------

--
-- Table structure for table `registered_user`
--

CREATE TABLE `registered_user`
(
    `user_id`  int(10)      NOT NULL,
    `username` varchar(20)  NOT NULL,
    `password` varchar(200) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `registered_user`
--

INSERT INTO `registered_user` (`user_id`, `username`, `password`)
VALUES (3, 'jaya', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (9, 'anuradha', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (10, 'misse', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (11, 'hiruna', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (12, 'kashyapa', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (13, 'hemaka', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (14, 'hashan', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (15, 'sanju', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (16, 'pasindu', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (17, 'basuru', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (15123, 'string', '$2a$10$TV9Wu5xkc9/krb.ptbYNlevXn0zHzECboVpJLbQv9VJR0h9XqTaeC'),
       (45269, 'string', '$2a$10$YaNL9a1AlWbiVns2n7/fRu.SbhUcJkKnkn/qr/SMtFVSNUuEHqhMq'),
       (59916, 'string', '$2a$10$N4o5TJv6c/VsDzDb6j6UvuxfxjGYQeJA/gibuPyLqt7B0o2p9tLlW'),
       (97559, 'string', '$2a$10$l4X7FNdsuCErbw9k6gVqD.xtVngF58XwZMivhKuMQgX9QW6zR4Ec2'),
       (234353, 'hyth', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (203018270, 'string', '$2a$10$jiv6wAqrSFRUUvXxQxtkuuOPED4YKXULiPMQO4oOAbKHmLf2aOqre'),
       (272995019, 'string', '$2a$10$VO.gwJIKRMnwDTKbD0n43.GDJkz5OBIRATaUGvdcpUGUibdGuVsbu'),
       (435029035, 'string', '$2a$10$tKLANhlLPx4YVaq9Jv2Pl.XaLP7vHfWkTn00m53Qxu03yP7M02sDm'),
       (483291754, 'bdhfbeiubfiuvbvv', '$2a$10$giFNizvkm3V1lavGV7rB3uplGuGiFZ4.vMgFj52EvY9Z.Q8B6Pp5G'),
       (559653779, 'bdhfbeiubfiuvbvv', '$2a$10$wNim6ZpT/GTh8w10kPfJX.0eEcM.ADzPKQPmHjnnVaB3xB1opCL76'),
       (602507817, 'string', '$2a$10$cJ.xepy2ZCEdrrB691ZTP.qVcnPi/aixJgOG0cRwRpe18.mTwzs6K'),
       (613604230, 'bdhfbeiubfiuvbvv', '$2a$10$8zWIrP0aSxpZ/LCGQXVsy.isiXstMd7JZTjql0B/2mTUc8cbgxY7G'),
       (876401798, 'string', '$2a$10$k5ph6Ia8zJcAIFgM5oZmwe.q.BD8zt7hnYqFxJ8.QApPdYs.0NhXu');

-- --------------------------------------------------------

--
-- Table structure for table `route`
--

CREATE TABLE `route`
(
    `route_id`    int(10) NOT NULL,
    `origin`      int(10) NOT NULL,
    `destination` int(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `route`
--

INSERT INTO `route` (`route_id`, `origin`, `destination`)
VALUES (1, 1, 2),
       (2, 1, 4),
       (4, 3, 5),
       (3, 4, 1),
       (6, 4, 2),
       (5, 6, 1);

--
-- Triggers `route`
--
DELIMITER $$
CREATE TRIGGER `checkroute`
    BEFORE INSERT
    ON `route`
    FOR EACH ROW
BEGIN
    DECLARE id1 int(10);

    SELECT `route_id`
    INTO id1
    FROM `route`
    WHERE route.origin = NEW.origin and route.destination = NEW.destination
    LIMIT 1;
    IF id1 is not NULL THEN
        SIGNAL SQLSTATE '45000';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `schedule`
--

CREATE TABLE `schedule`
(
    `schedule_id` int(10) NOT NULL,
    `date`        date    NOT NULL,
    `flight_id`   int(10) NOT NULL,
    `dep_time`    time    NOT NULL,
    `arival_time` time    NOT NULL,
    `gate_id`     int(10) NOT NULL,
    `delay`       time DEFAULT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `schedule`
--

INSERT INTO `schedule` (`schedule_id`, `date`, `flight_id`, `dep_time`, `arival_time`, `gate_id`, `delay`)
VALUES (1, '2020-01-16', 1, '09:13:00', '17:25:00', 1, NULL),
       (2, '2020-01-20', 1, '10:22:08', '15:06:00', 1, NULL),
       (3, '2020-01-15', 2, '05:00:00', '12:00:00', 3, NULL),
       (4, '2020-01-02', 1, '09:00:00', '07:00:00', 4, NULL),
       (5, '2020-01-20', 5, '23:00:00', '04:00:00', 37, NULL),
       (6, '2020-01-13', 3, '07:00:00', '06:00:00', 24, NULL),
       (7, '2020-01-20', 3, '07:21:00', '12:05:00', 25, NULL),
       (8, '2020-04-01', 4, '07:00:00', '10:00:00', 17, '00:00:00'),
       (9, '2020-08-14', 3, '03:00:00', '07:00:00', 26, NULL),
       (10, '2020-02-03', 6, '03:00:00', '08:00:00', 23, NULL);

--
-- Triggers `schedule`
--
DELIMITER $$
CREATE TRIGGER `check_flight_time_range_validity`
    AFTER INSERT
    ON `schedule`
    FOR EACH ROW
BEGIN

    #     set @airplane_id = (select airplane_id from schedule inner join flight f on schedule.flight_id = f.flight_id where schedule.flight_id =NEW.flight_id);
    SET @new_datetime_arrival = UNIX_TIMESTAMP(convert(concat(date, ' ', NEW.arival_time), datetime));
    SET @new_datetime_departure = UNIX_TIMESTAMP(convert(concat(date, ' ', NEW.dep_time), datetime));
    SET @old_datetime_departure = (select UNIX_TIMESTAMP(convert(concat(date, ' ', dep_time), datetime))
                                   from schedule
                                   where flight_id = NEW.flight_id);
    SET @old_datetime_arrival = (select UNIX_TIMESTAMP(convert(concat(date, ' ', arival_time), datetime))
                                 from schedule
                                 where flight_id = NEW.flight_id);
    IF not (@new_datetime_departure > @old_datetime_arrival OR @new_datetime_arrival < @old_datetime_departure) THEN
        SIGNAL SQLSTATE '45001';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_gates`
    BEFORE INSERT
    ON `schedule`
    FOR EACH ROW
BEGIN
    SET @id = NEW.flight_id;
    SET @id0 = NEW.gate_id;
    set @route_id = (SELECT route_id from flight WHERE flight_id = @id LIMIT 1);
    set @origin = (SELECT origin from route WHERE route_id = @route_id limit 1);
    set @yes = (SELECT IF(@id0 not in (SELECT gate_id from gate where airport_id = @origin), TRUE, FALSE));
    IF @yes THEN
        SIGNAL SQLSTATE '45000';

    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `schedule_details`
-- (See below for the actual view)
--
CREATE TABLE `schedule_details`
(
    `schedule_id` int(10),
    `date`        date,
    `origin`      varchar(50),
    `destination` varchar(50),
    `model_name`  varchar(30),
    `dep_time`    time,
    `arival_time` time,
    `name`        varchar(50)
);

-- --------------------------------------------------------

--
-- Table structure for table `seat`
--

CREATE TABLE `seat`
(
    `seat_id`   int(10)     NOT NULL,
    `model_id`  varchar(10) NOT NULL,
    `seat_name` varchar(10) NOT NULL,
    `class`     varchar(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `seat`
--

INSERT INTO `seat` (`seat_id`, `model_id`, `seat_name`, `class`)
VALUES (1, '0007', 'A1', 'E'),
       (2, '0007', 'A2', 'E'),
       (3, '0007', 'A3', 'E'),
       (4, '0007', 'A4', 'E'),
       (5, '0007', 'A5', 'E'),
       (6, '0007', 'A6', 'E'),
       (7, '0007', 'A7', 'E'),
       (8, '0007', 'A8', 'E'),
       (9, '0007', 'A9', 'E'),
       (10, '0007', 'B1', 'E'),
       (11, '0007', 'B2', 'E'),
       (12, '0007', 'B3', 'E'),
       (13, '0007', 'B4', 'E'),
       (14, '0007', 'B5', 'E'),
       (15, '0007', 'B6', 'E'),
       (16, '0007', 'B7', 'E'),
       (17, '0007', 'B8', 'E'),
       (18, '0007', 'B9', 'E'),
       (19, '0007', 'B10', 'E'),
       (20, '0007', 'C1', 'E'),
       (21, '0007', 'C2', 'E'),
       (22, '0007', 'C3', 'E'),
       (23, '0007', 'C4', 'E'),
       (24, '0007', 'C5', 'E'),
       (25, '0007', 'C6', 'E'),
       (26, '0007', 'C7', 'E'),
       (27, '0007', 'C8', 'E'),
       (28, '0007', 'C9', 'E'),
       (29, '0007', 'C10', 'E'),
       (30, '0007', 'A11', 'B'),
       (31, '0007', 'A12', 'B'),
       (32, '0007', 'B11', 'B'),
       (33, '0007', 'B12', 'B'),
       (34, '0007', 'C11', 'B'),
       (35, '0007', 'C12', 'B'),
       (41, '0008', 'A2', 'E'),
       (42, '0008', 'A3', 'E'),
       (43, '0008', 'A4', 'E'),
       (44, '0008', 'A5', 'E'),
       (45, '0008', 'A6', 'E'),
       (46, '0008', 'A7', 'E'),
       (47, '0008', 'A8', 'E'),
       (48, '0008', 'A9', 'E'),
       (49, '0008', 'B1', 'E'),
       (50, '0008', 'B2', 'E'),
       (51, '0008', 'B3', 'E'),
       (52, '0008', 'B4', 'E'),
       (53, '0008', 'B5', 'E'),
       (54, '0008', 'B6', 'E'),
       (55, '0008', 'B7', 'E'),
       (56, '0008', 'B8', 'E'),
       (57, '0008', 'B9', 'E'),
       (58, '0008', 'B10', 'E'),
       (59, '0008', 'C1', 'E'),
       (60, '0008', 'C2', 'E'),
       (61, '0008', 'C3', 'E'),
       (62, '0008', 'C4', 'E'),
       (63, '0008', 'C5', 'E'),
       (64, '0008', 'C6', 'E'),
       (65, '0008', 'C7', 'E'),
       (66, '0008', 'C8', 'E'),
       (67, '0008', 'C9', 'E'),
       (68, '0008', 'C10', 'E'),
       (69, '0008', 'A11', 'B'),
       (70, '0008', 'A12', 'B'),
       (71, '0008', 'B11', 'B'),
       (72, '0008', 'B12', 'B'),
       (73, '0008', 'C11', 'B'),
       (74, '0008', 'C12', 'B'),
       (75, '0001', 'A1', 'E'),
       (76, '0001', 'A2', 'E'),
       (77, '0001', 'A3', 'E'),
       (78, '0001', 'A4', 'E'),
       (79, '0001', 'A5', 'E'),
       (80, '0001', 'A6', 'E'),
       (81, '0001', 'A7', 'E'),
       (82, '0001', 'A8', 'E'),
       (83, '0001', 'A9', 'E'),
       (84, '0001', 'B1', 'E'),
       (85, '0001', 'B2', 'E'),
       (86, '0001', 'B3', 'E'),
       (87, '0001', 'B4', 'E'),
       (88, '0001', 'B5', 'E'),
       (89, '0001', 'B6', 'E'),
       (90, '0001', 'B7', 'E'),
       (91, '0001', 'B8', 'E'),
       (92, '0001', 'B9', 'E'),
       (93, '0001', 'B10', 'E'),
       (94, '0001', 'C1', 'E'),
       (95, '0001', 'C2', 'E'),
       (96, '0001', 'C3', 'E'),
       (97, '0001', 'C4', 'E'),
       (98, '0001', 'C5', 'E'),
       (99, '0001', 'C6', 'E'),
       (100, '0001', 'C7', 'E'),
       (101, '0001', 'C8', 'E'),
       (102, '0001', 'C9', 'E'),
       (103, '0001', 'C10', 'E'),
       (104, '0001', 'A11', 'B'),
       (105, '0001', 'A12', 'B'),
       (106, '0001', 'B11', 'B'),
       (107, '0001', 'B12', 'B'),
       (108, '0001', 'C11', 'B'),
       (109, '0001', 'C12', 'B'),
       (110, '0002', 'A1', 'E'),
       (111, '0002', 'A2', 'E'),
       (112, '0002', 'A3', 'E'),
       (113, '0002', 'A4', 'E'),
       (114, '0002', 'A5', 'E'),
       (115, '0002', 'A6', 'E'),
       (116, '0002', 'A7', 'E'),
       (117, '0002', 'A8', 'E'),
       (118, '0002', 'A9', 'E'),
       (119, '0002', 'B1', 'E'),
       (120, '0002', 'B2', 'E'),
       (121, '0002', 'B3', 'E'),
       (122, '0002', 'B4', 'E'),
       (123, '0002', 'B5', 'E'),
       (124, '0002', 'B6', 'E'),
       (125, '0002', 'B7', 'E'),
       (126, '0002', 'B8', 'E'),
       (127, '0002', 'B9', 'E'),
       (128, '0002', 'B10', 'E'),
       (129, '0002', 'C1', 'E'),
       (130, '0002', 'C2', 'E'),
       (131, '0002', 'C3', 'E'),
       (132, '0002', 'C4', 'E'),
       (133, '0002', 'C5', 'E'),
       (134, '0002', 'C6', 'E'),
       (135, '0002', 'C7', 'E'),
       (136, '0002', 'C8', 'E'),
       (137, '0002', 'C9', 'E'),
       (138, '0002', 'C10', 'E'),
       (139, '0002', 'A11', 'B'),
       (140, '0002', 'A12', 'B'),
       (141, '0002', 'B11', 'B'),
       (142, '0002', 'B12', 'B'),
       (143, '0002', 'C11', 'B'),
       (145, '0002', 'C12', 'B'),
       (146, '0003', 'A1', 'E'),
       (147, '0003', 'A2', 'E'),
       (148, '0003', 'A3', 'E'),
       (149, '0003', 'A4', 'E'),
       (150, '0003', 'A5', 'E'),
       (151, '0003', 'A6', 'E'),
       (152, '0003', 'A7', 'E'),
       (153, '0003', 'A8', 'E'),
       (154, '0003', 'A9', 'E'),
       (155, '0003', 'B1', 'E'),
       (156, '0003', 'B2', 'E'),
       (157, '0003', 'B3', 'E'),
       (158, '0003', 'B4', 'E'),
       (159, '0003', 'B5', 'E'),
       (160, '0003', 'B6', 'E'),
       (161, '0003', 'B7', 'E'),
       (162, '0003', 'B8', 'E'),
       (163, '0003', 'B9', 'E'),
       (164, '0003', 'B10', 'E'),
       (165, '0003', 'C1', 'E'),
       (166, '0003', 'C2', 'E'),
       (167, '0003', 'C3', 'E'),
       (168, '0003', 'C4', 'E'),
       (169, '0003', 'C5', 'E'),
       (170, '0003', 'C6', 'E'),
       (171, '0003', 'C7', 'E'),
       (172, '0003', 'C8', 'E'),
       (173, '0003', 'C9', 'E'),
       (174, '0003', 'C10', 'E'),
       (175, '0003', 'A11', 'B'),
       (176, '0003', 'A12', 'B'),
       (177, '0003', 'B11', 'B'),
       (178, '0003', 'B12', 'B'),
       (179, '0003', 'C11', 'B'),
       (180, '0003', 'C12', 'B'),
       (181, '0004', 'A1', 'E'),
       (182, '0004', 'A2', 'E'),
       (183, '0004', 'A3', 'E'),
       (184, '0004', 'A4', 'E'),
       (185, '0004', 'A5', 'E'),
       (186, '0004', 'A6', 'E'),
       (187, '0004', 'A7', 'E'),
       (188, '0004', 'A8', 'E'),
       (189, '0004', 'A9', 'E'),
       (190, '0004', 'B1', 'E'),
       (191, '0004', 'B2', 'E'),
       (192, '0004', 'B3', 'E'),
       (193, '0004', 'B4', 'E'),
       (194, '0004', 'B5', 'E'),
       (195, '0004', 'B6', 'E'),
       (196, '0004', 'B7', 'E'),
       (197, '0004', 'B8', 'E'),
       (198, '0004', 'B9', 'E'),
       (199, '0004', 'B10', 'E'),
       (200, '0004', 'C1', 'E'),
       (201, '0004', 'C2', 'E'),
       (202, '0004', 'C3', 'E'),
       (203, '0004', 'C4', 'E'),
       (204, '0004', 'C5', 'E'),
       (205, '0004', 'C6', 'E'),
       (206, '0004', 'C7', 'E'),
       (207, '0004', 'C8', 'E'),
       (208, '0004', 'C9', 'E'),
       (209, '0004', 'C10', 'E'),
       (210, '0004', 'A11', 'B'),
       (211, '0004', 'A12', 'B'),
       (212, '0004', 'B11', 'B'),
       (213, '0004', 'B12', 'B'),
       (214, '0004', 'C11', 'B'),
       (215, '0004', 'C12', 'B'),
       (216, '0005', 'A1', 'E'),
       (217, '0005', 'A2', 'E'),
       (218, '0005', 'A3', 'E'),
       (219, '0005', 'A4', 'E'),
       (220, '0005', 'A5', 'E'),
       (221, '0005', 'A6', 'E'),
       (222, '0005', 'A7', 'E'),
       (223, '0005', 'A8', 'E'),
       (224, '0005', 'A9', 'E'),
       (225, '0005', 'B1', 'E'),
       (226, '0005', 'B2', 'E'),
       (227, '0005', 'B3', 'E'),
       (228, '0005', 'B4', 'E'),
       (229, '0005', 'B5', 'E'),
       (230, '0005', 'B6', 'E'),
       (231, '0005', 'B7', 'E'),
       (232, '0005', 'B8', 'E'),
       (233, '0005', 'B9', 'E'),
       (234, '0005', 'B10', 'E'),
       (235, '0005', 'C1', 'E'),
       (236, '0005', 'C2', 'E'),
       (237, '0005', 'C3', 'E'),
       (238, '0005', 'C4', 'E'),
       (239, '0005', 'C5', 'E'),
       (240, '0005', 'C6', 'E'),
       (241, '0005', 'C7', 'E'),
       (242, '0005', 'C8', 'E'),
       (243, '0005', 'C9', 'E'),
       (244, '0005', 'C10', 'E'),
       (245, '0005', 'A11', 'B'),
       (246, '0005', 'A12', 'B'),
       (247, '0005', 'B11', 'B'),
       (248, '0005', 'B12', 'B'),
       (249, '0005', 'C11', 'B'),
       (250, '0005', 'C12', 'B'),
       (251, '0006', 'A1', 'E'),
       (252, '0006', 'A2', 'E'),
       (253, '0006', 'A3', 'E'),
       (254, '0006', 'A4', 'E'),
       (255, '0006', 'A5', 'E'),
       (256, '0006', 'A6', 'E'),
       (257, '0006', 'A7', 'E'),
       (258, '0006', 'A8', 'E'),
       (259, '0006', 'A9', 'E'),
       (260, '0006', 'B1', 'E'),
       (261, '0006', 'B2', 'E'),
       (262, '0006', 'B3', 'E'),
       (263, '0006', 'B4', 'E'),
       (264, '0006', 'B5', 'E'),
       (265, '0006', 'B6', 'E'),
       (266, '0006', 'B7', 'E'),
       (267, '0006', 'B8', 'E'),
       (268, '0006', 'B9', 'E'),
       (269, '0006', 'B10', 'E'),
       (270, '0006', 'C1', 'E'),
       (271, '0006', 'C2', 'E'),
       (272, '0006', 'C3', 'E'),
       (273, '0006', 'C4', 'E'),
       (274, '0006', 'C5', 'E'),
       (275, '0006', 'C6', 'E'),
       (276, '0006', 'C7', 'E'),
       (277, '0006', 'C8', 'E'),
       (278, '0006', 'C9', 'E'),
       (279, '0006', 'C10', 'E'),
       (280, '0006', 'A11', 'B'),
       (281, '0006', 'A12', 'B'),
       (282, '0006', 'B11', 'B'),
       (283, '0006', 'B12', 'B'),
       (284, '0006', 'C11', 'B'),
       (285, '0006', 'C12', 'B'),
       (286, '0009', 'A1', 'E'),
       (288, '0009', 'A2', 'E'),
       (289, '0009', 'A3', 'E'),
       (290, '0009', 'A4', 'E'),
       (291, '0009', 'A5', 'E'),
       (292, '0009', 'A6', 'E'),
       (293, '0009', 'A7', 'E'),
       (294, '0009', 'A8', 'E'),
       (295, '0009', 'A9', 'E'),
       (296, '0009', 'B1', 'E'),
       (297, '0009', 'B2', 'E'),
       (298, '0009', 'B3', 'E'),
       (299, '0009', 'B4', 'E'),
       (300, '0009', 'B5', 'E'),
       (301, '0009', 'B6', 'E'),
       (302, '0009', 'B7', 'E'),
       (303, '0009', 'B8', 'E'),
       (304, '0009', 'B9', 'E'),
       (305, '0009', 'B10', 'E'),
       (306, '0009', 'C1', 'E'),
       (307, '0009', 'C2', 'E'),
       (308, '0009', 'C3', 'E'),
       (309, '0009', 'C4', 'E'),
       (310, '0009', 'C5', 'E'),
       (311, '0009', 'C6', 'E'),
       (312, '0009', 'C7', 'E'),
       (313, '0009', 'C8', 'E'),
       (314, '0009', 'C9', 'E'),
       (315, '0009', 'C10', 'E'),
       (316, '0009', 'A11', 'B'),
       (317, '0009', 'A12', 'B'),
       (318, '0009', 'B11', 'B'),
       (319, '0009', 'B12', 'B'),
       (320, '0009', 'C11', 'B'),
       (321, '0009', 'C12', 'B'),
       (322, '0010', 'A1', 'E'),
       (323, '0010', 'A2', 'E'),
       (324, '0010', 'A3', 'E'),
       (325, '0010', 'A4', 'E'),
       (326, '0010', 'A5', 'E'),
       (327, '0010', 'A6', 'E'),
       (328, '0010', 'A7', 'E'),
       (329, '0010', 'A8', 'E'),
       (330, '0010', 'A9', 'E'),
       (331, '0010', 'B1', 'E'),
       (332, '0010', 'B2', 'E'),
       (333, '0010', 'B3', 'E'),
       (334, '0010', 'B4', 'E'),
       (335, '0010', 'B5', 'E'),
       (336, '0010', 'B6', 'E'),
       (337, '0010', 'B7', 'E'),
       (338, '0010', 'B8', 'E'),
       (339, '0010', 'B9', 'E'),
       (340, '0010', 'B10', 'E'),
       (341, '0010', 'C1', 'E'),
       (342, '0010', 'C2', 'E'),
       (343, '0010', 'C3', 'E'),
       (344, '0010', 'C4', 'E'),
       (345, '0010', 'C5', 'E'),
       (346, '0010', 'C6', 'E'),
       (347, '0010', 'C7', 'E'),
       (348, '0010', 'C8', 'E'),
       (349, '0010', 'C9', 'E'),
       (350, '0010', 'C10', 'E'),
       (351, '0010', 'A11', 'B'),
       (352, '0010', 'A12', 'B'),
       (353, '0010', 'B11', 'B'),
       (354, '0010', 'B12', 'B'),
       (355, '0010', 'C11', 'B'),
       (356, '0010', 'C12', 'B'),
       (357, '0011', 'A1', 'E'),
       (358, '0011', 'A2', 'E'),
       (359, '0011', 'A3', 'E'),
       (360, '0011', 'A4', 'E'),
       (361, '0011', 'A5', 'E'),
       (362, '0011', 'A6', 'E'),
       (363, '0011', 'A7', 'E'),
       (364, '0011', 'A8', 'E'),
       (365, '0011', 'A9', 'E'),
       (366, '0011', 'B1', 'E'),
       (367, '0011', 'B2', 'E'),
       (368, '0011', 'B3', 'E'),
       (369, '0011', 'B4', 'E'),
       (370, '0011', 'B5', 'E'),
       (371, '0011', 'B6', 'E'),
       (372, '0011', 'B7', 'E'),
       (373, '0011', 'B8', 'E'),
       (374, '0011', 'B9', 'E'),
       (375, '0011', 'B10', 'E'),
       (376, '0011', 'C1', 'E'),
       (377, '0011', 'C2', 'E'),
       (378, '0011', 'C3', 'E'),
       (379, '0011', 'C4', 'E'),
       (380, '0011', 'C5', 'E'),
       (381, '0011', 'C6', 'E'),
       (382, '0011', 'C7', 'E'),
       (383, '0011', 'C8', 'E'),
       (384, '0011', 'C9', 'E'),
       (385, '0011', 'C10', 'E'),
       (386, '0011', 'A11', 'B'),
       (387, '0011', 'A12', 'B'),
       (388, '0011', 'B11', 'B'),
       (389, '0011', 'B12', 'B'),
       (390, '0011', 'C11', 'B'),
       (391, '0011', 'C12', 'B'),
       (392, '0012', 'A1', 'E'),
       (393, '0012', 'A2', 'E'),
       (394, '0012', 'A3', 'E'),
       (395, '0012', 'A4', 'E'),
       (396, '0012', 'A5', 'E'),
       (397, '0012', 'A6', 'E'),
       (398, '0012', 'A7', 'E'),
       (399, '0012', 'A8', 'E'),
       (400, '0012', 'A9', 'E'),
       (401, '0012', 'B1', 'E'),
       (402, '0012', 'B2', 'E'),
       (403, '0012', 'B3', 'E'),
       (404, '0012', 'B4', 'E'),
       (405, '0012', 'B5', 'E'),
       (406, '0012', 'B6', 'E'),
       (407, '0012', 'B7', 'E'),
       (408, '0012', 'B8', 'E'),
       (409, '0012', 'B9', 'E'),
       (410, '0012', 'B10', 'E'),
       (411, '0012', 'C1', 'E'),
       (412, '0012', 'C2', 'E'),
       (413, '0012', 'C3', 'E'),
       (414, '0012', 'C4', 'E'),
       (415, '0012', 'C5', 'E'),
       (416, '0012', 'C6', 'E'),
       (417, '0012', 'C7', 'E'),
       (418, '0012', 'C8', 'E'),
       (419, '0012', 'C9', 'E'),
       (420, '0012', 'C10', 'E'),
       (421, '0012', 'A11', 'B'),
       (422, '0012', 'A12', 'B'),
       (423, '0012', 'B11', 'B'),
       (424, '0012', 'B12', 'B'),
       (425, '0012', 'C11', 'B'),
       (426, '0012', 'C12', 'B'),
       (427, '0013', 'A1', 'E'),
       (428, '0013', 'A2', 'E'),
       (429, '0013', 'A3', 'E'),
       (430, '0013', 'A4', 'E'),
       (431, '0013', 'A5', 'E'),
       (432, '0013', 'A6', 'E'),
       (433, '0013', 'A7', 'E'),
       (434, '0013', 'A8', 'E'),
       (435, '0013', 'A9', 'E'),
       (436, '0013', 'B1', 'E'),
       (437, '0013', 'B2', 'E'),
       (438, '0013', 'B3', 'E'),
       (439, '0013', 'B4', 'E'),
       (440, '0013', 'B5', 'E'),
       (441, '0013', 'B6', 'E'),
       (442, '0013', 'B7', 'E'),
       (443, '0013', 'B8', 'E'),
       (444, '0013', 'B9', 'E'),
       (445, '0013', 'B10', 'E'),
       (446, '0013', 'C1', 'E'),
       (447, '0013', 'C2', 'E'),
       (448, '0013', 'C3', 'E'),
       (449, '0013', 'C4', 'E'),
       (450, '0013', 'C5', 'E'),
       (451, '0013', 'C6', 'E'),
       (452, '0013', 'C7', 'E'),
       (453, '0013', 'C8', 'E'),
       (454, '0013', 'C9', 'E'),
       (455, '0013', 'C10', 'E'),
       (456, '0013', 'A11', 'B'),
       (457, '0013', 'A12', 'B'),
       (458, '0013', 'B11', 'B'),
       (459, '0013', 'B12', 'B'),
       (460, '0013', 'C11', 'B'),
       (461, '0013', 'C12', 'B');

-- --------------------------------------------------------

--
-- Stand-in structure for view `seat_details_according_to_schedule`
-- (See below for the actual view)
--
CREATE TABLE `seat_details_according_to_schedule`
(
    `schedule_id` int(10),
    `flight_id`   int(10),
    `price`       int(10),
    `seat_id`     int(10),
    `class`       varchar(10),
    `seat_name`   varchar(10),
    `model_id`    varchar(10)
);

-- --------------------------------------------------------

--
-- Table structure for table `seat_price`
--

CREATE TABLE `seat_price`
(
    `price_id`  int(10) NOT NULL,
    `price`     int(10) NOT NULL,
    `flight_id` int(10) NOT NULL,
    `seat_id`   int(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `seat_price`
--

INSERT INTO `seat_price` (`price_id`, `price`, `flight_id`, `seat_id`)
VALUES (1, 100000, 1, 75),
       (2, 120000, 1, 76),
       (3, 127000, 1, 77),
       (4, 123000, 1, 78),
       (5, 123400, 1, 79),
       (8, 140000, 1, 80),
       (9, 190000, 1, 81),
       (10, 130000, 1, 82),
       (12, 190800, 1, 83),
       (13, 100000, 1, 84),
       (14, 120000, 1, 85),
       (15, 127000, 1, 86),
       (16, 123000, 1, 87),
       (17, 123400, 1, 88),
       (18, 140000, 1, 89),
       (19, 190000, 1, 90),
       (20, 130000, 1, 91),
       (21, 190800, 1, 92),
       (34, 100000, 1, 93),
       (35, 120000, 1, 94),
       (36, 127000, 1, 95),
       (37, 123000, 1, 96),
       (38, 123400, 1, 97),
       (39, 140000, 1, 98),
       (40, 190000, 1, 99),
       (41, 130000, 1, 100),
       (42, 190800, 1, 101),
       (43, 100000, 1, 102),
       (44, 120000, 1, 103),
       (45, 127000, 1, 104),
       (46, 123000, 1, 105),
       (47, 123400, 1, 106),
       (48, 140000, 1, 107),
       (49, 190000, 1, 108),
       (50, 130000, 1, 109),
       (51, 100000, 2, 216),
       (52, 120000, 2, 217),
       (53, 127000, 2, 218),
       (54, 123000, 2, 219),
       (55, 123400, 2, 220),
       (56, 140000, 2, 221),
       (57, 190000, 2, 222),
       (58, 130000, 2, 223),
       (59, 190800, 2, 224),
       (60, 100000, 2, 225),
       (61, 120000, 2, 226),
       (62, 127000, 2, 227),
       (63, 123000, 2, 228),
       (64, 123400, 2, 229),
       (65, 140000, 2, 230),
       (66, 190000, 2, 231),
       (67, 130000, 2, 232),
       (68, 190800, 2, 233),
       (69, 100000, 2, 234),
       (70, 120000, 2, 235),
       (71, 127000, 2, 236),
       (72, 123000, 2, 237),
       (73, 123400, 2, 238),
       (74, 140000, 2, 239),
       (75, 190000, 2, 240),
       (76, 130000, 2, 241),
       (77, 190800, 2, 242),
       (78, 100000, 2, 243),
       (79, 120000, 2, 244),
       (80, 127000, 2, 245),
       (81, 123000, 2, 246),
       (82, 123400, 2, 247),
       (83, 140000, 2, 248),
       (84, 190000, 2, 249),
       (85, 130000, 2, 250),
       (86, 100000, 3, 181),
       (87, 120000, 3, 182),
       (88, 127000, 3, 183),
       (89, 123000, 3, 184),
       (90, 123400, 3, 185),
       (91, 140000, 3, 186),
       (92, 190000, 3, 187),
       (93, 130000, 3, 188),
       (94, 190800, 3, 189),
       (95, 100000, 3, 190),
       (96, 120000, 3, 191),
       (97, 127000, 3, 192),
       (98, 123000, 3, 193),
       (99, 123400, 3, 194),
       (100, 140000, 3, 195),
       (101, 190000, 3, 196),
       (102, 130000, 3, 197),
       (103, 190800, 3, 198),
       (104, 100000, 3, 199),
       (105, 120000, 3, 200),
       (106, 127000, 3, 201),
       (107, 123000, 3, 202),
       (108, 123400, 3, 203),
       (109, 140000, 3, 204),
       (110, 190000, 3, 205),
       (111, 130000, 3, 206),
       (112, 190800, 3, 207),
       (113, 100000, 3, 208),
       (114, 120000, 3, 209),
       (115, 127000, 3, 210),
       (116, 123000, 3, 211),
       (117, 123400, 3, 212),
       (118, 140000, 3, 213),
       (119, 190000, 3, 214),
       (120, 130000, 3, 215),
       (123, 100000, 4, 110),
       (124, 120000, 4, 111),
       (125, 127000, 4, 112),
       (126, 123000, 4, 113),
       (127, 123400, 4, 114),
       (128, 140000, 4, 115),
       (129, 190000, 4, 116),
       (130, 130000, 4, 117),
       (131, 190800, 4, 118),
       (132, 100000, 4, 119),
       (133, 120000, 4, 120),
       (134, 127000, 4, 121),
       (135, 123000, 4, 122),
       (136, 123400, 4, 123),
       (137, 140000, 4, 124),
       (138, 190000, 4, 125),
       (139, 130000, 4, 126),
       (140, 190800, 4, 127),
       (141, 100000, 4, 128),
       (142, 120000, 4, 129),
       (143, 127000, 4, 130),
       (144, 123000, 4, 131),
       (145, 123400, 4, 132),
       (146, 140000, 4, 133),
       (147, 190000, 4, 134),
       (148, 130000, 4, 136),
       (149, 190800, 4, 137),
       (150, 100000, 4, 138),
       (151, 120000, 4, 139),
       (152, 127000, 4, 140),
       (153, 123000, 4, 141),
       (154, 123400, 4, 142),
       (155, 140000, 4, 143),
       (156, 190000, 4, 145),
       (158, 100000, 5, 41),
       (159, 120000, 5, 42),
       (160, 127000, 5, 43),
       (161, 123000, 5, 44),
       (162, 123400, 5, 45),
       (163, 140000, 5, 46),
       (164, 190000, 5, 47),
       (165, 130000, 5, 48),
       (166, 190800, 5, 49),
       (167, 100000, 5, 50),
       (168, 120000, 5, 51),
       (169, 127000, 5, 52),
       (170, 123000, 5, 53),
       (171, 123400, 5, 54),
       (172, 140000, 5, 55),
       (173, 190000, 5, 56),
       (174, 130000, 5, 57),
       (175, 190800, 5, 58),
       (176, 100000, 5, 59),
       (177, 120000, 5, 60),
       (178, 127000, 5, 61),
       (179, 123000, 5, 62),
       (180, 123400, 5, 63),
       (181, 140000, 5, 64),
       (182, 190000, 5, 65),
       (183, 130000, 5, 66),
       (184, 190800, 5, 67),
       (185, 100000, 5, 68),
       (186, 120000, 5, 69),
       (187, 127000, 5, 70),
       (188, 123000, 5, 71),
       (189, 123400, 5, 72),
       (190, 140000, 5, 73),
       (191, 190000, 5, 74),
       (192, 130000, 5, 75),
       (193, 100000, 6, 1),
       (194, 120000, 6, 2),
       (195, 127000, 6, 3),
       (196, 123000, 6, 4),
       (197, 123400, 6, 5),
       (198, 140000, 6, 6),
       (199, 190000, 6, 7),
       (200, 130000, 6, 8),
       (201, 190800, 6, 9),
       (202, 100000, 6, 10),
       (203, 120000, 6, 11),
       (204, 127000, 6, 12),
       (205, 123000, 6, 13),
       (206, 123400, 6, 14),
       (207, 140000, 6, 15),
       (208, 190000, 6, 16),
       (209, 130000, 6, 17),
       (210, 190800, 6, 18),
       (211, 100000, 6, 19),
       (212, 120000, 6, 20),
       (213, 127000, 6, 21),
       (214, 123000, 6, 22),
       (215, 123400, 6, 23),
       (216, 140000, 6, 24),
       (217, 190000, 6, 25),
       (218, 130000, 6, 26),
       (219, 190800, 6, 27),
       (220, 100000, 6, 28),
       (221, 120000, 6, 29),
       (222, 127000, 6, 30),
       (223, 123000, 6, 31),
       (224, 123400, 6, 32),
       (225, 140000, 6, 33),
       (226, 190000, 6, 34),
       (227, 130000, 6, 35);

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff`
(
    `staff_id` int(10)     NOT NULL,
    `name`     varchar(20) NOT NULL,
    `nic`      varchar(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

-- --------------------------------------------------------

--
-- Table structure for table `staff_flight`
--

CREATE TABLE `staff_flight`
(
    `id`        int(11) NOT NULL,
    `staff_id`  int(10) NOT NULL,
    `flight_id` int(10) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user`
(
    `user_id`            int(10)     NOT NULL,
    `firstName`          varchar(20) NOT NULL,
    `secondName`         varchar(20) NOT NULL,
    `email`              varchar(30) NOT NULL,
    `nic`                varchar(10) DEFAULT NULL,
    `passport_id`        varchar(10) NOT NULL,
    `BirthDay`           date        NOT NULL,
    `user_type`          varchar(20) NOT NULL,
    `number_of_bookings` int(10)     NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `firstName`, `secondName`, `email`, `nic`, `passport_id`, `BirthDay`, `user_type`,
                    `number_of_bookings`)
VALUES (1, 'siri', 'madusanka', 'siri@gmail.com', '123456789v', '123456789', '1969-01-08', 'Frequent', 2),
       (2, 'shashi', 'mal', 'shashi@gamil.com', '223456789v', '223456789', '1969-01-08', 'Frequent', 2),
       (3, 'jaya', 'pathi', 'jaya@gmail.com', '323456789v', '323456789', '2009-12-10', 'Frequent', 2),
       (4, 'kushan', 'chami', 'kushan@gmail.com', '423456789v', '423456789', '1969-01-08', 'Frequent', 1),
       (5, 'amal', 'perara', 'amal@gmail.com', '523456789v', '523456789', '1969-01-08', 'Frequent', 3),
       (6, 'kamal', 'srimal', 'kamal@gmail.com', NULL, '623456789', '2009-12-10', 'Frequent', 1),
       (7, 'nimal', 'malindu', 'nimal@gmail.com', '723456789v', '723456789', '1969-01-08', '', 0),
       (8, 'shaluka', 'heshan', 'shaluka@gmail.com', '823456789v', '823456789', '2009-12-10', 'Frequent', 1),
       (9, 'anuradha', 'sirimewan', 'anuradha@gmail.com', '923456789v', '923456789', '1969-01-08', 'Frequent', 0),
       (10, 'misse', 'kumara', 'misse@gmail.com', '000000001v', '000000001', '2009-12-10', 'Frequent', 1),
       (11, 'hiruna', 'kumara', 'hiruna@gmail.com', '000000002v', '000000002', '1969-01-08', 'Frequent', 0),
       (12, 'kashyapa', 'nilame', 'kashyapa@gmail.com', '000000003v', '000000003', '2009-12-10', 'Frequent', 0),
       (13, 'hemaka', 'siya', 'hemaka@gmail.com', '000000004v', '000000004', '1969-01-08', 'Gold', 1),
       (14, 'hashan', 'madda', 'hashan@gmail.com', '000000005v', '000000005', '2009-12-10', 'Frequent', 1),
       (15, 'sanju', 'chikala', 'sanju@gmail.com', NULL, '000000006', '1969-01-08', 'Frequent', 0),
       (16, 'pasindu', 'akaya', 'pasindu@gmail.com', '000000007v', '000000007', '1969-01-08', 'Gold', 0),
       (17, 'basuru', 'pata', 'basuru@gmail.com', NULL, '000000008', '2009-12-10', 'Gold', 0),
       (15123, 'string', 'string', 'stringfjtyg', 'string', 'string', '2010-09-08', 'Gold', 0),
       (29893, 'string', 'string', 'jtytgjytg', 'string', 'string', '2019-03-02', 'Gold', 0),
       (45269, 'string', 'string', 'strjtygjtyging', 'string', 'string', '2019-08-23', 'Gold', 0),
       (59916, 'string', 'string', 'htrhfgbgfvb', 'string', 'string', '2010-09-08', 'Gold', 0),
       (82289, 'string', 'string', 'stringbfdhbfgbgfb', 'string', 'string', '2019-03-02', '', 0),
       (97559, 'string', 'string', 'stringgfdbfgbf', 'string', 'string', '2010-09-08', 'Gold', 0),
       (234353, 'dsfc', 'sdfcds', 'fcdsvfmujkmm', 'dsfv', 'dsfv', '2019-08-09', '', 0),
       (203018270, 'abc', 'abc', 'abc@gmail.com', 'string', 'string', '2019-12-31', 'Gold', 6),
       (272995019, 'string', 'string', 'stringdscdscsdcx', 'string', 'string', '2019-08-23', 'Gold', 0),
       (435029035, 'string', 'string', 'stringxsaxsax', 'string', 'string', '2019-08-23', 'Gold', 0),
       (483291754, 'string', 'string', 'stringsdwdff', 'string', 'string', '2019-08-23', 'Gold', 0),
       (559653779, 'string', 'string', 'stringdweffgvfb', 'string', 'string', '2019-08-23', '', 0),
       (602507817, 'string', 'string', 'stringfrgrtgg', 'string', 'string', '2019-08-23', 'Gold', 0),
       (613604230, 'string', 'string', 'stringgrtgtbffdg', 'string', 'string', '2019-08-23', 'Gold', 0),
       (876401798, 'string', 'string', 'stringtregfdcvdfbc', 'string', 'string', '2019-08-23', '', 0);

-- --------------------------------------------------------

--
-- Structure for view `book_details`
--
DROP TABLE IF EXISTS `book_details`;

CREATE ALGORITHM = UNDEFINED DEFINER =`root`@`localhost` SQL SECURITY DEFINER VIEW `book_details` AS
(
select `a`.`id`             AS `id`,
       `a`.`schedule_id`    AS `schedule_id`,
       `a`.`user_id`        AS `user_id`,
       `a`.`date`           AS `date`,
       `a`.`scheduled_date` AS `scheduled_date`,
       `a`.`origin`         AS `origin`,
       `a`.`destination`    AS `destination`,
       `a`.`airplane_model` AS `airplane_model`,
       `a`.`dep_time`       AS `dep_time`,
       `a`.`arival_time`    AS `arival_time`,
       `a`.`gate_name`      AS `gate_name`,
       `b`.`seat_name`      AS `seat_name`,
       `b`.`seat_class`     AS `seat_class`
from ((select `book`.`id`                      AS `id`,
              `book`.`schedule_id`             AS `schedule_id`,
              `book`.`date`                    AS `date`,
              `book`.`seat_id`                 AS `seat_id`,
              `book`.`user_id`                 AS `user_id`,
              `schedule_details`.`date`        AS `scheduled_date`,
              `schedule_details`.`origin`      AS `origin`,
              `schedule_details`.`destination` AS `destination`,
              `schedule_details`.`model_name`  AS `airplane_model`,
              `schedule_details`.`dep_time`    AS `dep_time`,
              `schedule_details`.`arival_time` AS `arival_time`,
              `schedule_details`.`name`        AS `gate_name`
       from (`book`
                join `schedule_details` on (`book`.`schedule_id` = `schedule_details`.`schedule_id`))) `a`
         join (select `book`.`id` AS `id`, `seat`.`seat_name` AS `seat_name`, `seat`.`class` AS `seat_class`
               from (`book`
                        join `seat` on (`book`.`seat_id` = `seat`.`seat_id`))) `b` on (`a`.`id` = `b`.`id`)));

-- --------------------------------------------------------

--
-- Structure for view `discount`
--
DROP TABLE IF EXISTS `discount`;

CREATE ALGORITHM = UNDEFINED DEFINER =`root`@`localhost` SQL SECURITY DEFINER VIEW `discount` AS
select `book`.`user_id` AS `user_id`, count(`book`.`user_id`) AS `trips`
from `book`
group by `book`.`user_id`;

-- --------------------------------------------------------

--
-- Structure for view `flight_details`
--
DROP TABLE IF EXISTS `flight_details`;

CREATE ALGORITHM = UNDEFINED DEFINER =`root`@`localhost` SQL SECURITY DEFINER VIEW `flight_details` AS
select `d`.`flight_id`   AS `flight_id`,
       `d`.`origin`      AS `origin`,
       `d`.`destination` AS `destination`,
       `e`.`model_name`  AS `model_name`
from ((select `flight`.`flight_id`   AS `flight_id`,
              `c`.`origin`           AS `origin`,
              `c`.`destination`      AS `destination`,
              `flight`.`airplane_id` AS `airplane_id`
       from ((select `a`.`route_id` AS `route_id`, `a`.`origin` AS `origin`, `b`.`destination` AS `destination`
              from ((select `route`.`route_id` AS `route_id`, `airport`.`name` AS `origin`
                     from (`route`
                              left join `airport` on (`route`.`origin` = `airport`.`airport_id`))) `a`
                       join (select `route`.`route_id` AS `route_id`, `airport`.`name` AS `destination`
                             from (`route`
                                      left join `airport` on (`route`.`destination` = `airport`.`airport_id`))) `b`
                            on (`a`.`route_id` = `b`.`route_id`))) `c`
                join `flight` on (`c`.`route_id` = `flight`.`route_id`))) `d`
         join (select `airplane`.`airplane_id` AS `airplane_id`, `airplane_model`.`model_name` AS `model_name`
               from (`airplane`
                        join `airplane_model` on (`airplane`.`model_id` = `airplane_model`.`model_id`))) `e`
              on (`d`.`airplane_id` = `e`.`airplane_id`));

-- --------------------------------------------------------

--
-- Structure for view `schedule_details`
--
DROP TABLE IF EXISTS `schedule_details`;

CREATE ALGORITHM = UNDEFINED DEFINER =`root`@`localhost` SQL SECURITY DEFINER VIEW `schedule_details` AS
select `ab`.`schedule_id` AS `schedule_id`,
       `ab`.`date`        AS `date`,
       `ab`.`origin`      AS `origin`,
       `ab`.`destination` AS `destination`,
       `ab`.`model_name`  AS `model_name`,
       `ab`.`dep_time`    AS `dep_time`,
       `ab`.`arival_time` AS `arival_time`,
       `gate`.`name`      AS `name`
from ((select `schedule`.`schedule_id`       AS `schedule_id`,
              `schedule`.`date`              AS `date`,
              `flight_details`.`origin`      AS `origin`,
              `flight_details`.`destination` AS `destination`,
              `flight_details`.`model_name`  AS `model_name`,
              `schedule`.`dep_time`          AS `dep_time`,
              `schedule`.`arival_time`       AS `arival_time`,
              `schedule`.`gate_id`           AS `gate_id`
       from (`schedule`
                join `flight_details` on (`schedule`.`flight_id` = `flight_details`.`flight_id`))) `ab`
         join `gate` on (`ab`.`gate_id` = `gate`.`gate_id`));

-- --------------------------------------------------------

--
-- Structure for view `seat_details_according_to_schedule`
--
DROP TABLE IF EXISTS `seat_details_according_to_schedule`;

CREATE ALGORITHM = UNDEFINED DEFINER =`root`@`localhost` SQL SECURITY DEFINER VIEW `seat_details_according_to_schedule` AS
select `a`.`schedule_id`  AS `schedule_id`,
       `a`.`flight_id`    AS `flight_id`,
       `a`.`price`        AS `price`,
       `a`.`seat_id`      AS `seat_id`,
       `seat`.`class`     AS `class`,
       `seat`.`seat_name` AS `seat_name`,
       `seat`.`model_id`  AS `model_id`
from ((select `schedule`.`schedule_id` AS `schedule_id`,
              `schedule`.`flight_id`   AS `flight_id`,
              `seat_price`.`price`     AS `price`,
              `seat_price`.`seat_id`   AS `seat_id`
       from (`schedule`
                join `seat_price` on (`schedule`.`flight_id` = `seat_price`.`flight_id`))) `a`
         join `seat` on (`a`.`seat_id` = `seat`.`seat_id`));

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
    ADD PRIMARY KEY (`admin_id`),
    ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `airplane`
--
ALTER TABLE `airplane`
    ADD PRIMARY KEY (`airplane_id`),
    ADD KEY `model_id` (`model_id`);

--
-- Indexes for table `airplane_model`
--
ALTER TABLE `airplane_model`
    ADD PRIMARY KEY (`model_id`),
    ADD KEY `model_name` (`model_name`);

--
-- Indexes for table `airport`
--
ALTER TABLE `airport`
    ADD PRIMARY KEY (`airport_id`),
    ADD UNIQUE KEY `location_id_2` (`location_id`, `code`),
    ADD KEY `location_id` (`location_id`),
    ADD KEY `code` (`code`);

--
-- Indexes for table `book`
--
ALTER TABLE `book`
    ADD PRIMARY KEY (`id`),
    ADD UNIQUE KEY `schedule_id_2` (`schedule_id`, `seat_id`),
    ADD KEY `schedule_id` (`schedule_id`),
    ADD KEY `seat_id` (`seat_id`),
    ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `cabin_crew`
--
ALTER TABLE `cabin_crew`
    ADD PRIMARY KEY (`staff_id`);

--
-- Indexes for table `flight`
--
ALTER TABLE `flight`
    ADD PRIMARY KEY (`flight_id`),
    ADD KEY `route_id` (`route_id`),
    ADD KEY `airplane_id` (`airplane_id`);

--
-- Indexes for table `gate`
--
ALTER TABLE `gate`
    ADD PRIMARY KEY (`gate_id`, `airport_id`),
    ADD UNIQUE KEY `airport_id` (`airport_id`, `name`),
    ADD UNIQUE KEY `gate_id` (`gate_id`, `airport_id`, `name`);

--
-- Indexes for table `guest_user`
--
ALTER TABLE `guest_user`
    ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `location`
--
ALTER TABLE `location`
    ADD KEY `child_id` (`child_id`),
    ADD KEY `parent_id` (`parent_id`),
    ADD KEY `location_id` (`location_id`);

--
-- Indexes for table `location_name`
--
ALTER TABLE `location_name`
    ADD PRIMARY KEY (`id`);

--
-- Indexes for table `passenger`
--
ALTER TABLE `passenger`
    ADD PRIMARY KEY (`id`),
    ADD KEY `book_id` (`book_id`),
    ADD KEY `id` (`id`);

--
-- Indexes for table `pilot`
--
ALTER TABLE `pilot`
    ADD PRIMARY KEY (`staff_id`);

--
-- Indexes for table `registered_user`
--
ALTER TABLE `registered_user`
    ADD UNIQUE KEY `user_id_2` (`user_id`),
    ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `route`
--
ALTER TABLE `route`
    ADD PRIMARY KEY (`route_id`),
    ADD UNIQUE KEY `origin_2` (`origin`, `destination`),
    ADD KEY `origin` (`origin`),
    ADD KEY `destination` (`destination`);

--
-- Indexes for table `schedule`
--
ALTER TABLE `schedule`
    ADD PRIMARY KEY (`schedule_id`),
    ADD KEY `flight_id` (`flight_id`),
    ADD KEY `gate_id` (`gate_id`),
    ADD KEY `dep_time` (`dep_time`),
    ADD KEY `arival_time` (`arival_time`);

--
-- Indexes for table `seat`
--
ALTER TABLE `seat`
    ADD PRIMARY KEY (`seat_id`),
    ADD UNIQUE KEY `seat_UN` (`model_id`, `seat_name`);

--
-- Indexes for table `seat_price`
--
ALTER TABLE `seat_price`
    ADD PRIMARY KEY (`price_id`),
    ADD UNIQUE KEY `flight_id_2` (`flight_id`, `seat_id`),
    ADD KEY `flight_id` (`flight_id`),
    ADD KEY `seat_id` (`seat_id`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
    ADD PRIMARY KEY (`staff_id`);

--
-- Indexes for table `staff_flight`
--
ALTER TABLE `staff_flight`
    ADD PRIMARY KEY (`id`),
    ADD KEY `staff_id` (`staff_id`),
    ADD KEY `flight_id` (`flight_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
    ADD PRIMARY KEY (`user_id`),
    ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
    MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 2;

--
-- AUTO_INCREMENT for table `airplane`
--
ALTER TABLE `airplane`
    MODIFY `airplane_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 14;

--
-- AUTO_INCREMENT for table `airport`
--
ALTER TABLE `airport`
    MODIFY `airport_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 7;

--
-- AUTO_INCREMENT for table `book`
--
ALTER TABLE `book`
    MODIFY `id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 98505716;

--
-- AUTO_INCREMENT for table `flight`
--
ALTER TABLE `flight`
    MODIFY `flight_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 7;

--
-- AUTO_INCREMENT for table `gate`
--
ALTER TABLE `gate`
    MODIFY `gate_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 40;

--
-- AUTO_INCREMENT for table `passenger`
--
ALTER TABLE `passenger`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 5;

--
-- AUTO_INCREMENT for table `route`
--
ALTER TABLE `route`
    MODIFY `route_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 7;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
    MODIFY `schedule_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 11;

--
-- AUTO_INCREMENT for table `seat`
--
ALTER TABLE `seat`
    MODIFY `seat_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 462;

--
-- AUTO_INCREMENT for table `seat_price`
--
ALTER TABLE `seat_price`
    MODIFY `price_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 228;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
    MODIFY `staff_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `staff_flight`
--
ALTER TABLE `staff_flight`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
    MODIFY `user_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 876401799;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `airplane`
--
ALTER TABLE `airplane`
    ADD CONSTRAINT `airplane_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `airplane_model` (`model_id`);

--
-- Constraints for table `airport`
--
ALTER TABLE `airport`
    ADD CONSTRAINT `airport_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`);

--
-- Constraints for table `book`
--
ALTER TABLE `book`
    ADD CONSTRAINT `book_ibfk_1` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`schedule_id`),
    ADD CONSTRAINT `book_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
    ADD CONSTRAINT `book_ibfk_4` FOREIGN KEY (`seat_id`) REFERENCES `seat` (`seat_id`);

--
-- Constraints for table `cabin_crew`
--
ALTER TABLE `cabin_crew`
    ADD CONSTRAINT `cabin_crew_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`);

--
-- Constraints for table `flight`
--
ALTER TABLE `flight`
    ADD CONSTRAINT `flight_ibfk_2` FOREIGN KEY (`airplane_id`) REFERENCES `airplane` (`airplane_id`),
    ADD CONSTRAINT `flight_ibfk_3` FOREIGN KEY (`route_id`) REFERENCES `route` (`route_id`);

--
-- Constraints for table `gate`
--
ALTER TABLE `gate`
    ADD CONSTRAINT `gate_ibfk_1` FOREIGN KEY (`airport_id`) REFERENCES `airport` (`airport_id`);

--
-- Constraints for table `guest_user`
--
ALTER TABLE `guest_user`
    ADD CONSTRAINT `guest_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `location`
--
ALTER TABLE `location`
    ADD CONSTRAINT `location_ibfk_2` FOREIGN KEY (`child_id`) REFERENCES `location_name` (`id`),
    ADD CONSTRAINT `location_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `location_name` (`id`),
    ADD CONSTRAINT `location_ibfk_4` FOREIGN KEY (`location_id`) REFERENCES `location_name` (`id`);

--
-- Constraints for table `passenger`
--
ALTER TABLE `passenger`
    ADD CONSTRAINT `passenger_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `book` (`id`);

--
-- Constraints for table `pilot`
--
ALTER TABLE `pilot`
    ADD CONSTRAINT `pilot_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`);

--
-- Constraints for table `registered_user`
--
ALTER TABLE `registered_user`
    ADD CONSTRAINT `registered_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `route`
--
ALTER TABLE `route`
    ADD CONSTRAINT `route_ibfk_1` FOREIGN KEY (`destination`) REFERENCES `airport` (`airport_id`),
    ADD CONSTRAINT `route_ibfk_2` FOREIGN KEY (`origin`) REFERENCES `airport` (`airport_id`);

--
-- Constraints for table `schedule`
--
ALTER TABLE `schedule`
    ADD CONSTRAINT `schedule_ibfk_3` FOREIGN KEY (`flight_id`) REFERENCES `flight` (`flight_id`),
    ADD CONSTRAINT `schedule_ibfk_4` FOREIGN KEY (`gate_id`) REFERENCES `gate` (`gate_id`);

--
-- Constraints for table `seat_price`
--
ALTER TABLE `seat_price`
    ADD CONSTRAINT `seat_price_ibfk_3` FOREIGN KEY (`flight_id`) REFERENCES `flight` (`flight_id`),
    ADD CONSTRAINT `seat_price_ibfk_4` FOREIGN KEY (`seat_id`) REFERENCES `seat` (`seat_id`);

--
-- Constraints for table `staff_flight`
--
ALTER TABLE `staff_flight`
    ADD CONSTRAINT `staff_flight_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`),
    ADD CONSTRAINT `staff_flight_ibfk_2` FOREIGN KEY (`flight_id`) REFERENCES `flight` (`flight_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT = @OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS = @OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION = @OLD_COLLATION_CONNECTION */;
