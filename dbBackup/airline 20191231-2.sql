-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 30, 2019 at 08:20 PM
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

    SELECT first_name                     as 'First Name',
           second_name                       'Last Name',
           email                          as 'Email',
           CONVERT(passport_id, char(30)) as 'Passport ID'
    from user
             NATURAL JOIN book
    WHERE book.schedule_id = @last
      and TIMESTAMPDIFF(YEAR, BirthDay, CURDATE()) >= 18;
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

    SELECT first_name                     as 'First Name',
           second_name                       'Last Name',
           email                          as 'Email',
           CONVERT(passport_id, char(30)) as 'Passport ID'
    from user
             NATURAL JOIN book
    WHERE book.schedule_id = @last
      and TIMESTAMPDIFF(YEAR, BirthDay, CURDATE()) <= 18;
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
    set @model_id = (SELECT model_id from airplane_model where model_name = model_name_in limit 1);
    set @airplane_id = (SELECT airplane_id FROM airplane where model_id = @model_id);
    set @flight_id = (SELECT flight_id from flight where airplane_id = @airplane_id);
    set @schedule_id = (SELECT schedule_id from schedule where flight_id = @flight_id);
    set @revenue = (SELECT sum(payment) from book where schedule_id = @schedule_id);
    RETURN @revenue;
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
    `admin_id` int(11)     NOT NULL,
    `username` varchar(20) NOT NULL,
    `password` varchar(20) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

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
VALUES (10, '0002'),
       (2, '0003'),
       (7, '0006'),
       (1, '0007'),
       (3, '0008'),
       (11, '0009'),
       (6, '0013'),
       (9, '0014'),
       (4, '0015'),
       (5, '0015'),
       (8, '0019');

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
       ('0016', 'Embraer ERJ 135'),
       ('0017', 'Embraer E-170'),
       ('0018', 'Ilyushin Il-96'),
       ('0019', 'Irkut MC-21'),
       ('0020', 'Mitsubishi Regional Jet'),
       ('1016', 'B737');

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
    `id`          int(10) NOT NULL,
    `date`        date    NOT NULL,
    `schedule_id` int(10) NOT NULL,
    `seat_id`     int(10) NOT NULL,
    `user_id`     int(10) NOT NULL,
    `payment`     double DEFAULT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

--
-- Dumping data for table `book`
--

INSERT INTO `book` (`id`, `date`, `schedule_id`, `seat_id`, `user_id`, `payment`)
VALUES (1, '2019-12-12', 1, 2, 2, NULL),
       (3, '2019-12-10', 1, 3, 11, NULL),
       (5, '2019-12-09', 1, 4, 13, NULL),
       (6, '2019-12-10', 2, 10, 8, NULL),
       (7, '2019-12-03', 2, 11, 6, NULL),
       (9, '2019-12-03', 2, 12, 15, NULL),
       (10, '2019-12-11', 2, 13, 14, NULL),
       (11, '2019-12-19', 3, 9, 12, NULL),
       (12, '2019-12-12', 1, 5, 1, NULL);

--
-- Triggers `book`
--
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
    `date`           date,
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
       (3, 2, 'E45'),
       (1, 2, 'kushan gate'),
       (4, 5, 'X23');

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
VALUES (9, 'anuradha', '12345'),
       (10, 'misse', '12345'),
       (11, 'hiruna', '12345'),
       (12, 'kashyapa', '12345'),
       (13, 'hemaka', '12345'),
       (14, 'hashan', '12345'),
       (15, 'sanju', '12345'),
       (16, 'pasindu', '12345'),
       (17, 'basuru', '12345'),
       (59916, 'string', '$2a$10$N4o5TJv6c/VsDzDb6j6UvuxfxjGYQeJA/gibuPyLqt7B0o2p9tLlW'),
       (97559, 'string', '$2a$10$l4X7FNdsuCErbw9k6gVqD.xtVngF58XwZMivhKuMQgX9QW6zR4Ec2'),
       (15123, 'string', '$2a$10$TV9Wu5xkc9/krb.ptbYNlevXn0zHzECboVpJLbQv9VJR0h9XqTaeC'),
       (45269, 'string', '$2a$10$YaNL9a1AlWbiVns2n7/fRu.SbhUcJkKnkn/qr/SMtFVSNUuEHqhMq'),
       (234353, 'hyth', 'hyth'),
       (272995019, 'string', '$2a$10$VO.gwJIKRMnwDTKbD0n43.GDJkz5OBIRATaUGvdcpUGUibdGuVsbu'),
       (435029035, 'string', '$2a$10$tKLANhlLPx4YVaq9Jv2Pl.XaLP7vHfWkTn00m53Qxu03yP7M02sDm'),
       (876401798, 'string', '$2a$10$k5ph6Ia8zJcAIFgM5oZmwe.q.BD8zt7hnYqFxJ8.QApPdYs.0NhXu'),
       (602507817, 'string', '$2a$10$cJ.xepy2ZCEdrrB691ZTP.qVcnPi/aixJgOG0cRwRpe18.mTwzs6K'),
       (559653779, 'bdhfbeiubfiuvbvv', '$2a$10$wNim6ZpT/GTh8w10kPfJX.0eEcM.ADzPKQPmHjnnVaB3xB1opCL76'),
       (483291754, 'bdhfbeiubfiuvbvv', '$2a$10$giFNizvkm3V1lavGV7rB3uplGuGiFZ4.vMgFj52EvY9Z.Q8B6Pp5G'),
       (613604230, 'bdhfbeiubfiuvbvv', '$2a$10$8zWIrP0aSxpZ/LCGQXVsy.isiXstMd7JZTjql0B/2mTUc8cbgxY7G');

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
    WHERE route.origin = NEW.origin
      and route.destination = NEW.destination
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
VALUES (1, '2019-12-20', 1, '09:13:00', '17:25:00', 1, NULL),
       (2, '2019-12-26', 1, '10:22:08', '15:06:00', 1, NULL),
       (3, '2019-12-13', 2, '05:00:00', '12:00:00', 3, NULL);

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
VALUES (1, '0007', '21 C', 'E'),
       (2, '0007', '21 A', 'E'),
       (3, '0007', '22 C', 'E'),
       (4, '0007', 'B12', 'E'),
       (5, '0007', 'B23', 'E'),
       (6, '0015', 'A02', 'B'),
       (7, '0015', 'A03', 'B'),
       (8, '0015', 'A23', 'E'),
       (9, '0015', 'A22', 'E'),
       (10, '0003', 'A18', 'B'),
       (11, '0003', 'C23', 'E'),
       (12, '0003', 'C22', 'E'),
       (13, '0003', 'A14', 'B');

-- --------------------------------------------------------

--
-- Stand-in structure for view `seat_details_according_to_schedule`
-- (See below for the actual view)
--
CREATE TABLE `seat_details_according_to_schedule`
(
    `schedule_id` int(10),
    `seat_id`     int(10),
    `seat_name`   varchar(10),
    `seat_class`  varchar(10),
    `flight_id`   int(10),
    `seat_price`  int(10)
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
VALUES (1, 100000, 1, 1),
       (2, 120000, 1, 2),
       (3, 127000, 1, 3),
       (4, 123000, 2, 2),
       (5, 123400, 1, 12),
       (8, 140000, 2, 13),
       (9, 190000, 1, 4),
       (12, 130000, 1, 8),
       (13, 190800, 1, 13);

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
VALUES (1, 'siri', 'madusanka', 'siri@gmail.com', '123456789v', '123456789', '2019-01-08', '', 0),
       (2, 'shashi', 'mal', 'shashi@gamil.com', '223456789v', '223456789', '2019-12-13', '', 0),
       (3, 'jayan', 'pathi', 'jayan@gmail.com', '323456789v', '323456789', '2019-12-10', '', 0),
       (4, 'kushan', 'chami', 'kushan@gmail.com', '423456789v', '423456789', '0000-00-00', '', 0),
       (5, 'amal', 'perara', 'amal@gmail.com', '523456789v', '523456789', '0000-00-00', '', 0),
       (6, 'kamal', 'srimal', 'kamal@gmail.com', NULL, '623456789', '0000-00-00', '', 0),
       (7, 'nimal', 'malindu', 'nimal@gmail.com', '723456789v', '723456789', '0000-00-00', '', 0),
       (8, 'shaluka', 'heshan', 'shaluka@gmail.com', '823456789v', '823456789', '0000-00-00', '', 0),
       (9, 'anuradha', 'sirimewan', 'anuradha@gmail.com', '923456789v', '923456789', '0000-00-00', '', 0),
       (10, 'misse', 'kumara', 'misse@gmail.com', '000000001v', '000000001', '0000-00-00', '', 0),
       (11, 'hiruna', 'kumara', 'hiruna@gmail.com', '000000002v', '000000002', '0000-00-00', '', 0),
       (12, 'kashyapa', 'nilame', 'kashyapa@gmail.com', '000000003v', '000000003', '0000-00-00', '', 0),
       (13, 'hemaka', 'siya', 'hemaka@gmail.com', '000000004v', '000000004', '0000-00-00', '', 0),
       (14, 'hashan', 'madda', 'hashan@gmail.com', '000000005v', '000000005', '0000-00-00', '', 0),
       (15, 'sanju', 'chikala', 'sanju@gmail.com', NULL, '000000006', '0000-00-00', '', 0),
       (16, 'pasindu', 'akaya', 'pasindu@gmail.com', '000000007v', '000000007', '0000-00-00', '', 0),
       (17, 'basuru', 'pata', 'basuru@gmail.com', NULL, '000000008', '0000-00-00', '', 0),
       (15123, 'string', 'string', 'stringfjtyg', 'string', 'string', '2010-09-08', 'bug', 0),
       (29893, 'string', 'string', 'jtytgjytg', 'string', 'string', '2019-03-02', 'bug', 0),
       (45269, 'string', 'string', 'strjtygjtyging', 'string', 'string', '2019-08-23', 'bug', 0),
       (59916, 'string', 'string', 'htrhfgbgfvb', 'string', 'string', '2010-09-08', 'bug', 0),
       (82289, 'string', 'string', 'stringbfdhbfgbgfb', 'string', 'string', '2019-03-02', 'bug', 0),
       (97559, 'string', 'string', 'stringgfdbfgbf', 'string', 'string', '2010-09-08', 'bug', 0),
       (234353, 'dsfc', 'sdfcds', 'fcdsvfmujkmm', 'dsfv', 'dsfv', '2019-08-09', '', 0),
       (272995019, 'string', 'string', 'stringdscdscsdcx', 'string', 'string', '2019-08-23', '', 0),
       (435029035, 'string', 'string', 'stringxsaxsax', 'string', 'string', '2019-08-23', '', 0),
       (483291754, 'string', 'string', 'stringsdwdff', 'string', 'string', '2019-08-23', '', 0),
       (559653779, 'string', 'string', 'stringdweffgvfb', 'string', 'string', '2019-08-23', '', 0),
       (602507817, 'string', 'string', 'stringfrgrtgg', 'string', 'string', '2019-08-23', '', 0),
       (613604230, 'string', 'string', 'stringgrtgtbffdg', 'string', 'string', '2019-08-23', '', 0),
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
select `a`.`schedule_id`    AS `schedule_id`,
       `a`.`seat_id`        AS `seat_id`,
       `a`.`seat_name`      AS `seat_name`,
       `a`.`seat_class`     AS `seat_class`,
       `a`.`flight_id`      AS `flight_id`,
       `seat_price`.`price` AS `seat_price`
from ((select `schedule`.`schedule_id` AS `schedule_id`,
              `seat`.`seat_id`         AS `seat_id`,
              `seat`.`seat_name`       AS `seat_name`,
              `seat`.`class`           AS `seat_class`,
              `flight`.`flight_id`     AS `flight_id`
       from (((`schedule` join `flight` on (`schedule`.`flight_id` = `flight`.`flight_id`)) join `airplane` on (`flight`.`airplane_id` = `airplane`.`airplane_id`))
                join `seat` on (`airplane`.`model_id` = `seat`.`model_id`))) `a`
         left join `seat_price`
                   on (`a`.`flight_id` = `seat_price`.`flight_id` and `a`.`seat_id` = `seat_price`.`seat_id`));

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
    ADD PRIMARY KEY (`admin_id`);

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
    ADD PRIMARY KEY (`model_id`);

--
-- Indexes for table `airport`
--
ALTER TABLE `airport`
    ADD PRIMARY KEY (`airport_id`),
    ADD UNIQUE KEY `location_id_2` (`location_id`, `code`),
    ADD KEY `location_id` (`location_id`);

--
-- Indexes for table `book`
--
ALTER TABLE `book`
    ADD PRIMARY KEY (`id`),
    ADD UNIQUE KEY `schedule_id_2` (`schedule_id`, `seat_id`, `user_id`),
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
-- Indexes for table `pilot`
--
ALTER TABLE `pilot`
    ADD PRIMARY KEY (`staff_id`);

--
-- Indexes for table `registered_user`
--
ALTER TABLE `registered_user`
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
    ADD KEY `gate_id` (`gate_id`);

--
-- Indexes for table `seat`
--
ALTER TABLE `seat`
    ADD PRIMARY KEY (`seat_id`),
    ADD UNIQUE KEY `seat_name` (`seat_name`);

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
    MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `airplane`
--
ALTER TABLE `airplane`
    MODIFY `airplane_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 12;

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
    AUTO_INCREMENT = 35;

--
-- AUTO_INCREMENT for table `flight`
--
ALTER TABLE `flight`
    MODIFY `flight_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 9;

--
-- AUTO_INCREMENT for table `gate`
--
ALTER TABLE `gate`
    MODIFY `gate_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 10;

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
    AUTO_INCREMENT = 4;

--
-- AUTO_INCREMENT for table `seat_price`
--
ALTER TABLE `seat_price`
    MODIFY `price_id` int(10) NOT NULL AUTO_INCREMENT,
    AUTO_INCREMENT = 25;

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
    ADD CONSTRAINT `book_ibfk_2` FOREIGN KEY (`seat_id`) REFERENCES `seat` (`seat_id`),
    ADD CONSTRAINT `book_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

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
    ADD CONSTRAINT `seat_price_ibfk_2` FOREIGN KEY (`seat_id`) REFERENCES `seat` (`seat_id`),
    ADD CONSTRAINT `seat_price_ibfk_3` FOREIGN KEY (`flight_id`) REFERENCES `flight` (`flight_id`);

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
