--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: DATABASE optic_db; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON DATABASE CURRENT_CATALOG IS '{0,0}';


--
-- Name: DATABASE optic_db; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON DATABASE CURRENT_CATALOG IS ON;


--
-- Name: SCHEMA public; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON SCHEMA public IS '{0,0}';


--
-- Name: SCHEMA public; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON SCHEMA public IS ON;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: EXTENSION plpgsql; Type: MAC LABEL; Schema: -; Owner: 
--

MAC LABEL ON EXTENSION plpgsql IS '{0,0}';


SET search_path = public, pg_catalog;

--
-- Name: delete_old_trace(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION delete_old_trace() RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE start_trace_id integer;
	DECLARE del_count integer;
	DECLARE res_count integer;
	DECLARE cur_date DATE;
BEGIN
	-- **************** Очистка данных за текущие день.
	-- Определяем последнюю дату снятых трасс в БД
	SELECT MAX(trace_date) FROM trace INTO cur_date;
	-- Определяем идентификатор последней рефлектограммы в этот день
	SELECT MAX(id_trace) FROM trace INTO start_trace_id WHERE (trace_date=cur_date);
	-- За последний день сбора информации оставляем последние 10 записей.
	start_trace_id := start_trace_id - 10;
	-- Более ранние трассы, каждую 5-тую оставляем, остальные удаляем.
	DELETE FROM trace WHERE (id_trace<=start_trace_id)AND(trace_date=cur_date)AND(id_trace%5>0);
	
	-- **************** Очистка данных за предыдущий рабочий день.
	-- Определяем предпоследнюю дату снятых трасс в БД.
	-- Не просто вычитаем 1, а именно смотрим по базе предыдущий день.
	SELECT MAX(trace_date) FROM trace WHERE trace_date<cur_date INTO cur_date;
	-- Определяем идентификатор первой рефлектограммы в этот день
	SELECT MIN(id_trace) FROM trace INTO start_trace_id WHERE trace_date=cur_date;
	-- Определяем общее число снятых трасс
	SELECT COUNT(*) FROM trace INTO del_count WHERE trace_date=cur_date;
	IF (del_count>1) THEN
		-- Удаляем записи, если их было более 1 в этот день.
		DELETE FROM trace WHERE (id_trace>start_trace_id)AND(trace_date=cur_date);
	end IF;
	
	-- **************** Проверяем результат удаление - число оставшихся в БД трасс за день.
	SELECT COUNT(*) FROM trace INTO res_count WHERE trace_date=cur_date;
	RETURN del_count*1000+res_count;
END;
$$;


ALTER FUNCTION public.delete_old_trace() OWNER TO postgres;

--
-- Name: FUNCTION delete_old_trace(); Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON FUNCTION delete_old_trace() IS '{0,0}';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: alarm; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alarm (
    id_alarm integer NOT NULL,
    id_user integer,
    alarm_type integer,
    alarm_status integer,
    id_alarm_levels integer,
    id_fiber integer,
    alarm_start timestamp(0) without time zone,
    alarm_close timestamp(0) without time zone,
    comment character varying(255),
    statuschanged timestamp(0) without time zone,
    ackstatus boolean,
    fiber_status integer,
    id_alarm_trace integer,
    "dB" integer,
    point integer,
    "pointEnd" integer,
    delta double precision,
    "IndexDelta" integer,
    algorithm integer
);


ALTER TABLE alarm OWNER TO postgres;

--
-- Name: TABLE alarm; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE alarm IS '{0,0}';


--
-- Name: TABLE alarm; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE alarm IS ON;


--
-- Name: alarm_id_alarm_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alarm_id_alarm_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alarm_id_alarm_seq OWNER TO postgres;

--
-- Name: alarm_id_alarm_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alarm_id_alarm_seq OWNED BY alarm.id_alarm;


--
-- Name: SEQUENCE alarm_id_alarm_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE alarm_id_alarm_seq IS '{0,0}';


--
-- Name: SEQUENCE alarm_id_alarm_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE alarm_id_alarm_seq IS ON;


--
-- Name: alarm_levels; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alarm_levels (
    id_alarm_level smallint NOT NULL,
    name character varying(255),
    "dB" real
);


ALTER TABLE alarm_levels OWNER TO postgres;

--
-- Name: TABLE alarm_levels; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE alarm_levels IS '{0,0}';


--
-- Name: TABLE alarm_levels; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE alarm_levels IS ON;


--
-- Name: alarm_levels_id_alarm_level_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alarm_levels_id_alarm_level_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alarm_levels_id_alarm_level_seq OWNER TO postgres;

--
-- Name: alarm_levels_id_alarm_level_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alarm_levels_id_alarm_level_seq OWNED BY alarm_levels.id_alarm_level;


--
-- Name: SEQUENCE alarm_levels_id_alarm_level_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE alarm_levels_id_alarm_level_seq IS '{0,0}';


--
-- Name: SEQUENCE alarm_levels_id_alarm_level_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE alarm_levels_id_alarm_level_seq IS ON;


--
-- Name: alarm_trace; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alarm_trace (
    id_alarm_trace bigint NOT NULL,
    id_fiber integer,
    etalon_dots bytea,
    rfdots bytea,
    last_trace bytea,
    bdiff bytea,
    sumb bytea
);


ALTER TABLE alarm_trace OWNER TO postgres;

--
-- Name: TABLE alarm_trace; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE alarm_trace IS 'предполагается, что хранит байтовые массивы точек эталона на тот момент и точек обыкновенных';


--
-- Name: COLUMN alarm_trace.id_alarm_trace; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN alarm_trace.id_alarm_trace IS 'айдишка для этой таблицы не для хрен пойми чего, а просто потому что надо';


--
-- Name: COLUMN alarm_trace.rfdots; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN alarm_trace.rfdots IS 'аварийная рефлектограмма';


--
-- Name: COLUMN alarm_trace.last_trace; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN alarm_trace.last_trace IS 'предыдущая рефлектограмма перед аварийной';


--
-- Name: COLUMN alarm_trace.bdiff; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN alarm_trace.bdiff IS 'разница коэффициентов b между эталоном и нынешней рефлектограммой';


--
-- Name: COLUMN alarm_trace.sumb; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN alarm_trace.sumb IS 'суммы разниц B между эталоном и аварийной рефлетограммой';


--
-- Name: TABLE alarm_trace; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE alarm_trace IS '{0,0}';


--
-- Name: TABLE alarm_trace; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE alarm_trace IS ON;


--
-- Name: alarm_trace_id_alarm_trace_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alarm_trace_id_alarm_trace_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alarm_trace_id_alarm_trace_seq OWNER TO postgres;

--
-- Name: alarm_trace_id_alarm_trace_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alarm_trace_id_alarm_trace_seq OWNED BY alarm_trace.id_alarm_trace;


--
-- Name: SEQUENCE alarm_trace_id_alarm_trace_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE alarm_trace_id_alarm_trace_seq IS '{0,0}';


--
-- Name: SEQUENCE alarm_trace_id_alarm_trace_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE alarm_trace_id_alarm_trace_seq IS ON;


--
-- Name: alfa_compare; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alfa_compare (
    id_alfa_compare bigint NOT NULL,
    id_trace integer,
    alfa real
);


ALTER TABLE alfa_compare OWNER TO postgres;

--
-- Name: TABLE alfa_compare; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE alfa_compare IS '{0,0}';


--
-- Name: TABLE alfa_compare; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE alfa_compare IS ON;


--
-- Name: alfa_compare_id_alfa_compare_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alfa_compare_id_alfa_compare_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alfa_compare_id_alfa_compare_seq OWNER TO postgres;

--
-- Name: alfa_compare_id_alfa_compare_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alfa_compare_id_alfa_compare_seq OWNED BY alfa_compare.id_alfa_compare;


--
-- Name: SEQUENCE alfa_compare_id_alfa_compare_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE alfa_compare_id_alfa_compare_seq IS '{0,0}';


--
-- Name: SEQUENCE alfa_compare_id_alfa_compare_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE alfa_compare_id_alfa_compare_seq IS ON;


--
-- Name: attenuation; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE attenuation (
    id_attenuation integer NOT NULL,
    variationwarning double precision,
    variationminor double precision,
    variationmajor double precision,
    variationcritical double precision
);


ALTER TABLE attenuation OWNER TO postgres;

--
-- Name: TABLE attenuation; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE attenuation IS '{0,0}';


--
-- Name: TABLE attenuation; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE attenuation IS ON;


--
-- Name: attenuation_id_attenuation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE attenuation_id_attenuation_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE attenuation_id_attenuation_seq OWNER TO postgres;

--
-- Name: attenuation_id_attenuation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE attenuation_id_attenuation_seq OWNED BY attenuation.id_attenuation;


--
-- Name: SEQUENCE attenuation_id_attenuation_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE attenuation_id_attenuation_seq IS '{0,0}';


--
-- Name: SEQUENCE attenuation_id_attenuation_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE attenuation_id_attenuation_seq IS ON;


--
-- Name: cable; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cable (
    id_cable integer NOT NULL,
    id_fiber_group integer,
    cable_name character varying(255),
    cable_fibercount integer,
    cable_type character varying(255),
    cable_length integer
);


ALTER TABLE cable OWNER TO postgres;

--
-- Name: TABLE cable; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE cable IS '{0,0}';


--
-- Name: TABLE cable; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE cable IS ON;


--
-- Name: cable_id_cable_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cable_id_cable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cable_id_cable_seq OWNER TO postgres;

--
-- Name: cable_id_cable_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cable_id_cable_seq OWNED BY cable.id_cable;


--
-- Name: SEQUENCE cable_id_cable_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE cable_id_cable_seq IS '{0,0}';


--
-- Name: SEQUENCE cable_id_cable_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE cable_id_cable_seq IS ON;


--
-- Name: debug; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE debug (
    id_debug integer,
    "111" double precision,
    id double precision[],
    dot double precision
);


ALTER TABLE debug OWNER TO postgres;

--
-- Name: TABLE debug; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE debug IS '{0,0}';


--
-- Name: TABLE debug; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE debug IS ON;


--
-- Name: fib_segm_data; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE fib_segm_data (
    id_fib_segm integer NOT NULL,
    id_fiber_segments smallint,
    algorithm integer,
    bmin double precision,
    bmax double precision,
    sumbmin double precision,
    sumbmax double precision,
    bvalues bytea,
    sumbvalues bytea
);


ALTER TABLE fib_segm_data OWNER TO postgres;

--
-- Name: TABLE fib_segm_data; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE fib_segm_data IS '{0,0}';


--
-- Name: TABLE fib_segm_data; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE fib_segm_data IS ON;


--
-- Name: fiber; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE fiber (
    id_fiber integer NOT NULL,
    id_otdr integer,
    segments_max integer,
    fiber_name character varying(255),
    fiber_length integer,
    fiber_type boolean DEFAULT true,
    fiber_info text,
    "on" boolean DEFAULT false,
    channel integer,
    sumbmax double precision,
    sumbmaxindex integer,
    summaxindex integer
);


ALTER TABLE fiber OWNER TO postgres;

--
-- Name: COLUMN fiber.segments_max; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber.segments_max IS 'количество точек или метров, которое может быть в прямом отрезки. Ибо чем они дальше от лазера, тем больше шумов. ';


--
-- Name: COLUMN fiber.sumbmax; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber.sumbmax IS 'Максимум по суммам разницы коэффициентов b по количеству точек аппроксимации по алгоритму с кодовым названием "Алгоритм Сергея Николаевича"';


--
-- Name: COLUMN fiber.sumbmaxindex; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber.sumbmaxindex IS 'индекс значения из столбца sumbmax';


--
-- Name: TABLE fiber; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE fiber IS '{0,0}';


--
-- Name: TABLE fiber; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE fiber IS ON;


--
-- Name: fiber_id_fiber_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE fiber_id_fiber_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE fiber_id_fiber_seq OWNER TO postgres;

--
-- Name: fiber_id_fiber_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE fiber_id_fiber_seq OWNED BY fiber.id_fiber;


--
-- Name: SEQUENCE fiber_id_fiber_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE fiber_id_fiber_seq IS '{0,0}';


--
-- Name: SEQUENCE fiber_id_fiber_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE fiber_id_fiber_seq IS ON;


--
-- Name: fiber_segments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE fiber_segments (
    id_fiber_segments smallint NOT NULL,
    id_fiber integer,
    start real,
    "end" real,
    bmin double precision,
    bmax double precision,
    linearity boolean,
    id_segment smallint,
    sigma double precision,
    bmingl double precision,
    bmaxgl double precision,
    bgl double precision,
    summin double precision,
    summax double precision,
    sumbmin double precision,
    sumbmax double precision,
    sumbminindex integer,
    sumbmaxindex integer,
    summinindex integer,
    summaxindex integer
);


ALTER TABLE fiber_segments OWNER TO postgres;

--
-- Name: COLUMN fiber_segments.bmin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.bmin IS 'минимум разниц коэффициентов на этом участке';


--
-- Name: COLUMN fiber_segments.bmax; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.bmax IS 'максимум разниц коэффициентов B';


--
-- Name: COLUMN fiber_segments.linearity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.linearity IS 'линейный отрезок или неоднородность. 
0 - линейный
1 - неоднородность';


--
-- Name: COLUMN fiber_segments.id_segment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.id_segment IS 'Для порядкового номера сегмента, дабы делать выборки и изменения в уже существующих сегментах. Иначе получается шляпа. Ну либо я пока не придумала как лучше';


--
-- Name: COLUMN fiber_segments.bmingl; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.bmingl IS 'минимальная разница между коэффициентами аппроксимации по n точек и глобальному b по отрезку';


--
-- Name: COLUMN fiber_segments.bmaxgl; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.bmaxgl IS 'максимальная разница между коэффициентами аппроксимации по n точек и глобальному b по отрезку';


--
-- Name: COLUMN fiber_segments.bgl; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.bgl IS 'коэффициент b по всему отрезку';


--
-- Name: COLUMN fiber_segments.summin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.summin IS 'минимум по суммам коэффициента b по n значений';


--
-- Name: COLUMN fiber_segments.summax; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.summax IS 'минимум по суммам коэффициента b по n значений';


--
-- Name: COLUMN fiber_segments.sumbmin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.sumbmin IS 'Минимум по суммам разницы коэффициентов b по кличеству точек аппроксимации по алгоритму с кодовым названием "Алгоритм Сергея Николаевича"';


--
-- Name: COLUMN fiber_segments.sumbmax; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.sumbmax IS 'Максимум по суммам разницы коэффициентов b по кличеству точек аппроксимации по алгоритму с кодовым названием "Алгоритм Сергея Николаевича"';


--
-- Name: COLUMN fiber_segments.sumbminindex; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.sumbminindex IS 'индекс значения из столбца sumbmin';


--
-- Name: COLUMN fiber_segments.sumbmaxindex; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fiber_segments.sumbmaxindex IS 'индекс значения из столбца sumbmax';


--
-- Name: TABLE fiber_segments; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE fiber_segments IS '{0,0}';


--
-- Name: TABLE fiber_segments; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE fiber_segments IS ON;


--
-- Name: fiber_segments_id_fiber_segments_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE fiber_segments_id_fiber_segments_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE fiber_segments_id_fiber_segments_seq OWNER TO postgres;

--
-- Name: fiber_segments_id_fiber_segments_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE fiber_segments_id_fiber_segments_seq OWNED BY fiber_segments.id_fiber_segments;


--
-- Name: SEQUENCE fiber_segments_id_fiber_segments_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE fiber_segments_id_fiber_segments_seq IS '{0,0}';


--
-- Name: SEQUENCE fiber_segments_id_fiber_segments_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE fiber_segments_id_fiber_segments_seq IS ON;


--
-- Name: last_trace_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE last_trace_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE last_trace_id_seq OWNER TO postgres;

--
-- Name: SEQUENCE last_trace_id_seq; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON SEQUENCE last_trace_id_seq IS 'to set id automatically';


--
-- Name: SEQUENCE last_trace_id_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE last_trace_id_seq IS '{0,0}';


--
-- Name: SEQUENCE last_trace_id_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE last_trace_id_seq IS ON;


--
-- Name: last_trace; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE last_trace (
    id_last_trace bigint DEFAULT nextval('last_trace_id_seq'::regclass) NOT NULL,
    last_update timestamp without time zone,
    id_fiber integer,
    trace_dots bytea
);


ALTER TABLE last_trace OWNER TO postgres;

--
-- Name: TABLE last_trace; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE last_trace IS 'contains last reflectogramm on fiber';


--
-- Name: COLUMN last_trace.id_last_trace; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN last_trace.id_last_trace IS 'I don''t know why, but it should be so';


--
-- Name: TABLE last_trace; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE last_trace IS '{0,0}';


--
-- Name: TABLE last_trace; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE last_trace IS ON;


--
-- Name: map_value; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE map_value (
    id_map_value integer NOT NULL,
    id_cable integer,
    map_x double precision,
    map_y double precision
);


ALTER TABLE map_value OWNER TO postgres;

--
-- Name: TABLE map_value; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE map_value IS '{0,0}';


--
-- Name: TABLE map_value; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE map_value IS ON;


--
-- Name: map_value_id_map_value_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE map_value_id_map_value_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE map_value_id_map_value_seq OWNER TO postgres;

--
-- Name: map_value_id_map_value_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE map_value_id_map_value_seq OWNED BY map_value.id_map_value;


--
-- Name: SEQUENCE map_value_id_map_value_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE map_value_id_map_value_seq IS '{0,0}';


--
-- Name: SEQUENCE map_value_id_map_value_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE map_value_id_map_value_seq IS ON;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE migrations (
    version bigint NOT NULL
);


ALTER TABLE migrations OWNER TO postgres;

--
-- Name: TABLE migrations; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE migrations IS '{0,0}';


--
-- Name: TABLE migrations; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE migrations IS ON;


--
-- Name: new_peak; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE new_peak (
    id_new_peak integer NOT NULL,
    warn double precision,
    minor double precision,
    major double precision,
    critical double precision
);


ALTER TABLE new_peak OWNER TO postgres;

--
-- Name: TABLE new_peak; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE new_peak IS '{0,0}';


--
-- Name: TABLE new_peak; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE new_peak IS ON;


--
-- Name: new_peak_id_new_peak_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE new_peak_id_new_peak_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE new_peak_id_new_peak_seq OWNER TO postgres;

--
-- Name: new_peak_id_new_peak_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE new_peak_id_new_peak_seq OWNED BY new_peak.id_new_peak;


--
-- Name: SEQUENCE new_peak_id_new_peak_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE new_peak_id_new_peak_seq IS '{0,0}';


--
-- Name: SEQUENCE new_peak_id_new_peak_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE new_peak_id_new_peak_seq IS ON;


--
-- Name: optic_users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE optic_users (
    id_user integer NOT NULL,
    user_name character varying(255),
    pass character varying(128),
    perpission integer
);


ALTER TABLE optic_users OWNER TO postgres;

--
-- Name: TABLE optic_users; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE optic_users IS '{0,0}';


--
-- Name: TABLE optic_users; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE optic_users IS ON;


--
-- Name: optic_users_id_user_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE optic_users_id_user_seq
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE optic_users_id_user_seq OWNER TO postgres;

--
-- Name: optic_users_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE optic_users_id_user_seq OWNED BY optic_users.id_user;


--
-- Name: SEQUENCE optic_users_id_user_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE optic_users_id_user_seq IS '{0,0}';


--
-- Name: SEQUENCE optic_users_id_user_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE optic_users_id_user_seq IS ON;


--
-- Name: otdr; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE otdr (
    id_otdr integer NOT NULL,
    otdr_name character varying(255),
    otdr_active boolean,
    otdr_ports_count integer,
    otdr_imei character varying(128),
    otdr_poverka date,
    otdr_active_channel integer
);


ALTER TABLE otdr OWNER TO postgres;

--
-- Name: TABLE otdr; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE otdr IS '{0,0}';


--
-- Name: TABLE otdr; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE otdr IS ON;


--
-- Name: otdr_id_otdr_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE otdr_id_otdr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE otdr_id_otdr_seq OWNER TO postgres;

--
-- Name: otdr_id_otdr_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE otdr_id_otdr_seq OWNED BY otdr.id_otdr;


--
-- Name: SEQUENCE otdr_id_otdr_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE otdr_id_otdr_seq IS '{0,0}';


--
-- Name: SEQUENCE otdr_id_otdr_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE otdr_id_otdr_seq IS ON;


--
-- Name: pulse_duration; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pulse_duration (
    id_pulse_duration integer NOT NULL,
    id_otdr integer,
    value integer
);


ALTER TABLE pulse_duration OWNER TO postgres;

--
-- Name: TABLE pulse_duration; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE pulse_duration IS '{0,0}';


--
-- Name: TABLE pulse_duration; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE pulse_duration IS ON;


--
-- Name: pulse_duration_id_pulse_duration_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pulse_duration_id_pulse_duration_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pulse_duration_id_pulse_duration_seq OWNER TO postgres;

--
-- Name: pulse_duration_id_pulse_duration_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pulse_duration_id_pulse_duration_seq OWNED BY pulse_duration.id_pulse_duration;


--
-- Name: SEQUENCE pulse_duration_id_pulse_duration_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE pulse_duration_id_pulse_duration_seq IS '{0,0}';


--
-- Name: SEQUENCE pulse_duration_id_pulse_duration_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE pulse_duration_id_pulse_duration_seq IS ON;


--
-- Name: rangeoflength; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE rangeoflength (
    id_range_of_length integer NOT NULL,
    id_otdr integer,
    value integer
);


ALTER TABLE rangeoflength OWNER TO postgres;

--
-- Name: TABLE rangeoflength; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE rangeoflength IS '{0,0}';


--
-- Name: TABLE rangeoflength; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE rangeoflength IS ON;


--
-- Name: rangeoflength_id_range_of_length_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE rangeoflength_id_range_of_length_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rangeoflength_id_range_of_length_seq OWNER TO postgres;

--
-- Name: rangeoflength_id_range_of_length_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE rangeoflength_id_range_of_length_seq OWNED BY rangeoflength.id_range_of_length;


--
-- Name: SEQUENCE rangeoflength_id_range_of_length_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE rangeoflength_id_range_of_length_seq IS '{0,0}';


--
-- Name: SEQUENCE rangeoflength_id_range_of_length_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE rangeoflength_id_range_of_length_seq IS ON;


--
-- Name: reference_dots; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE reference_dots (
    id_reference_dots integer NOT NULL,
    id_fiber integer,
    last_update timestamp without time zone,
    trace_dots bytea
);


ALTER TABLE reference_dots OWNER TO postgres;

--
-- Name: TABLE reference_dots; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE reference_dots IS 'таблица для хранения исключительно точек эталонных рефлектограмм';


--
-- Name: COLUMN reference_dots.last_update; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN reference_dots.last_update IS 'последнее усреднение эталонной рефлектограммы';


--
-- Name: COLUMN reference_dots.trace_dots; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN reference_dots.trace_dots IS 'непосредственно точки нашей рефлетограммы';


--
-- Name: TABLE reference_dots; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE reference_dots IS '{0,0}';


--
-- Name: TABLE reference_dots; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE reference_dots IS ON;


--
-- Name: reference_dots_id_reference_dots_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE reference_dots_id_reference_dots_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reference_dots_id_reference_dots_seq OWNER TO postgres;

--
-- Name: reference_dots_id_reference_dots_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE reference_dots_id_reference_dots_seq OWNED BY reference_dots.id_reference_dots;


--
-- Name: SEQUENCE reference_dots_id_reference_dots_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE reference_dots_id_reference_dots_seq IS '{0,0}';


--
-- Name: SEQUENCE reference_dots_id_reference_dots_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE reference_dots_id_reference_dots_seq IS ON;


--
-- Name: reference_trace; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE reference_trace (
    id_trace integer NOT NULL,
    id_fiber integer,
    trace_date timestamp without time zone,
    ds integer,
    count integer,
    wave integer,
    pulse integer,
    id_user integer,
    range integer,
    average_time integer,
    appr_point integer,
    gi double precision,
    number_of_average integer,
    indexmax double precision,
    segment_max integer
);


ALTER TABLE reference_trace OWNER TO postgres;

--
-- Name: COLUMN reference_trace.appr_point; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN reference_trace.appr_point IS 'количество точек аппроксимации, посчитанное в зависимости от ds и кол-ва точек. ';


--
-- Name: COLUMN reference_trace.number_of_average; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN reference_trace.number_of_average IS 'количество усреднений рефлектограммы (на два больше, чем записано)';


--
-- Name: COLUMN reference_trace.indexmax; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN reference_trace.indexmax IS 'индекс, на который надо умножать наши максимумы, чтобы не получилась белебердень';


--
-- Name: COLUMN reference_trace.segment_max; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN reference_trace.segment_max IS 'максимальное количество точек в одном отрезке';


--
-- Name: TABLE reference_trace; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE reference_trace IS '{0,0}';


--
-- Name: TABLE reference_trace; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE reference_trace IS ON;


--
-- Name: reference_trace_id_trace_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE reference_trace_id_trace_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reference_trace_id_trace_seq OWNER TO postgres;

--
-- Name: reference_trace_id_trace_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE reference_trace_id_trace_seq OWNED BY reference_trace.id_trace;


--
-- Name: SEQUENCE reference_trace_id_trace_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE reference_trace_id_trace_seq IS '{0,0}';


--
-- Name: SEQUENCE reference_trace_id_trace_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE reference_trace_id_trace_seq IS ON;


--
-- Name: schedule; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE schedule (
    id_schedule bigint NOT NULL,
    id_fiber integer NOT NULL,
    "interval" integer DEFAULT 0 NOT NULL,
    enabled boolean NOT NULL,
    last_update timestamp without time zone,
    start_monitoring timestamp without time zone
);


ALTER TABLE schedule OWNER TO postgres;

--
-- Name: COLUMN schedule.start_monitoring; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN schedule.start_monitoring IS 'начало того, как мы начали мониторить';


--
-- Name: TABLE schedule; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE schedule IS '{0,0}';


--
-- Name: TABLE schedule; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE schedule IS ON;


--
-- Name: schedule_id_schedule_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE schedule_id_schedule_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE schedule_id_schedule_seq OWNER TO postgres;

--
-- Name: schedule_id_schedule_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE schedule_id_schedule_seq OWNED BY schedule.id_schedule;


--
-- Name: SEQUENCE schedule_id_schedule_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE schedule_id_schedule_seq IS '{0,0}';


--
-- Name: SEQUENCE schedule_id_schedule_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE schedule_id_schedule_seq IS ON;


--
-- Name: segments_alfas; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE segments_alfas (
    id_segments_alfas bigint NOT NULL,
    id_fiber_segments integer,
    bmin double precision,
    bmax double precision,
    id_fiber integer,
    summax double precision,
    summin double precision,
    bminaver double precision,
    bmaxaver double precision,
    "time" timestamp without time zone,
    summaxaver double precision,
    summinaver double precision
);


ALTER TABLE segments_alfas OWNER TO postgres;

--
-- Name: TABLE segments_alfas; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE segments_alfas IS 'хранит минимум и максимум по отрезкам';


--
-- Name: TABLE segments_alfas; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE segments_alfas IS '{0,0}';


--
-- Name: TABLE segments_alfas; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE segments_alfas IS ON;


--
-- Name: segments_alfas_id_segments_alfas_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE segments_alfas_id_segments_alfas_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE segments_alfas_id_segments_alfas_seq OWNER TO postgres;

--
-- Name: segments_alfas_id_segments_alfas_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE segments_alfas_id_segments_alfas_seq OWNED BY segments_alfas.id_segments_alfas;


--
-- Name: SEQUENCE segments_alfas_id_segments_alfas_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE segments_alfas_id_segments_alfas_seq IS '{0,0}';


--
-- Name: SEQUENCE segments_alfas_id_segments_alfas_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE segments_alfas_id_segments_alfas_seq IS ON;


--
-- Name: sumb_compare; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sumb_compare (
    id_sumb_compare bigint NOT NULL,
    id_trace integer,
    alfa real
);


ALTER TABLE sumb_compare OWNER TO postgres;

--
-- Name: TABLE sumb_compare; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE sumb_compare IS '{0,0}';


--
-- Name: TABLE sumb_compare; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE sumb_compare IS ON;


--
-- Name: sumb_compare_id_sumb_compare_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sumb_compare_id_sumb_compare_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sumb_compare_id_sumb_compare_seq OWNER TO postgres;

--
-- Name: sumb_compare_id_sumb_compare_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sumb_compare_id_sumb_compare_seq OWNED BY sumb_compare.id_sumb_compare;


--
-- Name: SEQUENCE sumb_compare_id_sumb_compare_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE sumb_compare_id_sumb_compare_seq IS '{0,0}';


--
-- Name: SEQUENCE sumb_compare_id_sumb_compare_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE sumb_compare_id_sumb_compare_seq IS ON;


--
-- Name: system; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE system (
    id_system integer NOT NULL,
    ssh_man boolean,
    ssh_work boolean,
    ipaddr_work character varying(255),
    netmask character varying(255),
    gw character varying(255),
    dns character varying(255),
    dns2 character varying(255),
    domain_name character varying(255) DEFAULT 'SMURF'::character varying
);


ALTER TABLE system OWNER TO postgres;

--
-- Name: TABLE system; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE system IS '{0,0}';


--
-- Name: TABLE system; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE system IS ON;


--
-- Name: system_id_system_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE system_id_system_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE system_id_system_seq OWNER TO postgres;

--
-- Name: system_id_system_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE system_id_system_seq OWNED BY system.id_system;


--
-- Name: SEQUENCE system_id_system_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE system_id_system_seq IS '{0,0}';


--
-- Name: SEQUENCE system_id_system_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE system_id_system_seq IS ON;


--
-- Name: systemlog; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE systemlog (
    id_systemlog integer NOT NULL,
    id_user integer,
    message character varying(255),
    datetime date
);


ALTER TABLE systemlog OWNER TO postgres;

--
-- Name: TABLE systemlog; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE systemlog IS '{0,0}';


--
-- Name: TABLE systemlog; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE systemlog IS ON;


--
-- Name: systemlog_id_systemlog_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE systemlog_id_systemlog_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE systemlog_id_systemlog_seq OWNER TO postgres;

--
-- Name: systemlog_id_systemlog_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE systemlog_id_systemlog_seq OWNED BY systemlog.id_systemlog;


--
-- Name: SEQUENCE systemlog_id_systemlog_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE systemlog_id_systemlog_seq IS '{0,0}';


--
-- Name: SEQUENCE systemlog_id_systemlog_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE systemlog_id_systemlog_seq IS ON;


--
-- Name: test; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE test (
    id_test integer NOT NULL,
    id_fiber integer,
    test_name character varying(255),
    pulse_duration integer,
    time_accum integer,
    range_of_length integer,
    wavelength integer
);


ALTER TABLE test OWNER TO postgres;

--
-- Name: TABLE test; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE test IS '{0,0}';


--
-- Name: TABLE test; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE test IS ON;


--
-- Name: test_id_test_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE test_id_test_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE test_id_test_seq OWNER TO postgres;

--
-- Name: test_id_test_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE test_id_test_seq OWNED BY test.id_test;


--
-- Name: SEQUENCE test_id_test_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE test_id_test_seq IS '{0,0}';


--
-- Name: SEQUENCE test_id_test_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE test_id_test_seq IS ON;


--
-- Name: time_accum; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE time_accum (
    id_time_occum integer NOT NULL,
    id_otdr integer,
    value integer
);


ALTER TABLE time_accum OWNER TO postgres;

--
-- Name: TABLE time_accum; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE time_accum IS '{0,0}';


--
-- Name: TABLE time_accum; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE time_accum IS ON;


--
-- Name: time_accum_id_time_occum_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE time_accum_id_time_occum_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE time_accum_id_time_occum_seq OWNER TO postgres;

--
-- Name: time_accum_id_time_occum_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE time_accum_id_time_occum_seq OWNED BY time_accum.id_time_occum;


--
-- Name: SEQUENCE time_accum_id_time_occum_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE time_accum_id_time_occum_seq IS '{0,0}';


--
-- Name: SEQUENCE time_accum_id_time_occum_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE time_accum_id_time_occum_seq IS ON;


--
-- Name: trace; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE trace (
    id_trace integer NOT NULL,
    id_fiber integer,
    id_user integer,
    id_alarm integer,
    trace_date timestamp without time zone,
    ds integer,
    average_time integer,
    count integer,
    wave integer,
    pulse integer,
    range integer
);


ALTER TABLE trace OWNER TO postgres;

--
-- Name: TABLE trace; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE trace IS '{0,0}';


--
-- Name: TABLE trace; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE trace IS ON;


--
-- Name: trace_id_trace_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE trace_id_trace_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE trace_id_trace_seq OWNER TO postgres;

--
-- Name: trace_id_trace_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE trace_id_trace_seq OWNED BY trace.id_trace;


--
-- Name: SEQUENCE trace_id_trace_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE trace_id_trace_seq IS '{0,0}';


--
-- Name: SEQUENCE trace_id_trace_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE trace_id_trace_seq IS ON;


--
-- Name: urgent_action; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE urgent_action (
    id_urgent_action bigint NOT NULL,
    id_fiber integer,
    action integer
);


ALTER TABLE urgent_action OWNER TO postgres;

--
-- Name: TABLE urgent_action; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE urgent_action IS '{0,0}';


--
-- Name: TABLE urgent_action; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE urgent_action IS ON;


--
-- Name: urgent_action_id_urgent_action_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE urgent_action_id_urgent_action_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE urgent_action_id_urgent_action_seq OWNER TO postgres;

--
-- Name: urgent_action_id_urgent_action_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE urgent_action_id_urgent_action_seq OWNED BY urgent_action.id_urgent_action;


--
-- Name: SEQUENCE urgent_action_id_urgent_action_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE urgent_action_id_urgent_action_seq IS '{0,0}';


--
-- Name: SEQUENCE urgent_action_id_urgent_action_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE urgent_action_id_urgent_action_seq IS ON;


--
-- Name: wavelength; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wavelength (
    id_wavelength integer NOT NULL,
    id_otdr integer,
    value integer
);


ALTER TABLE wavelength OWNER TO postgres;

--
-- Name: TABLE wavelength; Type: MAC LABEL; Schema: -; Owner: postgres
--

MAC LABEL ON TABLE wavelength IS '{0,0}';


--
-- Name: TABLE wavelength; Type: MAC CCR; Schema: -; Owner: postgres
--

MAC CCR ON TABLE wavelength IS ON;


--
-- Name: wavelength_id_wavelength_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE wavelength_id_wavelength_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wavelength_id_wavelength_seq OWNER TO postgres;

--
-- Name: wavelength_id_wavelength_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE wavelength_id_wavelength_seq OWNED BY wavelength.id_wavelength;


--
-- Name: SEQUENCE wavelength_id_wavelength_seq; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON SEQUENCE wavelength_id_wavelength_seq IS '{0,0}';


--
-- Name: SEQUENCE wavelength_id_wavelength_seq; Type: MAC CCR; Schema: public; Owner: postgres
--

MAC CCR ON SEQUENCE wavelength_id_wavelength_seq IS ON;


--
-- Name: id_alarm; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alarm ALTER COLUMN id_alarm SET DEFAULT nextval('alarm_id_alarm_seq'::regclass);


--
-- Name: id_alarm_level; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alarm_levels ALTER COLUMN id_alarm_level SET DEFAULT nextval('alarm_levels_id_alarm_level_seq'::regclass);


--
-- Name: id_alarm_trace; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alarm_trace ALTER COLUMN id_alarm_trace SET DEFAULT nextval('alarm_trace_id_alarm_trace_seq'::regclass);


--
-- Name: id_alfa_compare; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alfa_compare ALTER COLUMN id_alfa_compare SET DEFAULT nextval('alfa_compare_id_alfa_compare_seq'::regclass);


--
-- Name: id_attenuation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY attenuation ALTER COLUMN id_attenuation SET DEFAULT nextval('attenuation_id_attenuation_seq'::regclass);


--
-- Name: id_cable; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cable ALTER COLUMN id_cable SET DEFAULT nextval('cable_id_cable_seq'::regclass);


--
-- Name: id_fiber; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fiber ALTER COLUMN id_fiber SET DEFAULT nextval('fiber_id_fiber_seq'::regclass);


--
-- Name: id_fiber_segments; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fiber_segments ALTER COLUMN id_fiber_segments SET DEFAULT nextval('fiber_segments_id_fiber_segments_seq'::regclass);


--
-- Name: id_map_value; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY map_value ALTER COLUMN id_map_value SET DEFAULT nextval('map_value_id_map_value_seq'::regclass);


--
-- Name: id_new_peak; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY new_peak ALTER COLUMN id_new_peak SET DEFAULT nextval('new_peak_id_new_peak_seq'::regclass);


--
-- Name: id_user; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY optic_users ALTER COLUMN id_user SET DEFAULT nextval('optic_users_id_user_seq'::regclass);


--
-- Name: id_otdr; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY otdr ALTER COLUMN id_otdr SET DEFAULT nextval('otdr_id_otdr_seq'::regclass);


--
-- Name: id_pulse_duration; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pulse_duration ALTER COLUMN id_pulse_duration SET DEFAULT nextval('pulse_duration_id_pulse_duration_seq'::regclass);


--
-- Name: id_range_of_length; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rangeoflength ALTER COLUMN id_range_of_length SET DEFAULT nextval('rangeoflength_id_range_of_length_seq'::regclass);


--
-- Name: id_reference_dots; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reference_dots ALTER COLUMN id_reference_dots SET DEFAULT nextval('reference_dots_id_reference_dots_seq'::regclass);


--
-- Name: id_trace; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reference_trace ALTER COLUMN id_trace SET DEFAULT nextval('reference_trace_id_trace_seq'::regclass);


--
-- Name: id_schedule; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY schedule ALTER COLUMN id_schedule SET DEFAULT nextval('schedule_id_schedule_seq'::regclass);


--
-- Name: id_segments_alfas; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY segments_alfas ALTER COLUMN id_segments_alfas SET DEFAULT nextval('segments_alfas_id_segments_alfas_seq'::regclass);


--
-- Name: id_sumb_compare; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sumb_compare ALTER COLUMN id_sumb_compare SET DEFAULT nextval('sumb_compare_id_sumb_compare_seq'::regclass);


--
-- Name: id_system; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY system ALTER COLUMN id_system SET DEFAULT nextval('system_id_system_seq'::regclass);


--
-- Name: id_systemlog; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY systemlog ALTER COLUMN id_systemlog SET DEFAULT nextval('systemlog_id_systemlog_seq'::regclass);


--
-- Name: id_test; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY test ALTER COLUMN id_test SET DEFAULT nextval('test_id_test_seq'::regclass);


--
-- Name: id_time_occum; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY time_accum ALTER COLUMN id_time_occum SET DEFAULT nextval('time_accum_id_time_occum_seq'::regclass);


--
-- Name: id_trace; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trace ALTER COLUMN id_trace SET DEFAULT nextval('trace_id_trace_seq'::regclass);


--
-- Name: id_urgent_action; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY urgent_action ALTER COLUMN id_urgent_action SET DEFAULT nextval('urgent_action_id_urgent_action_seq'::regclass);


--
-- Name: id_wavelength; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wavelength ALTER COLUMN id_wavelength SET DEFAULT nextval('wavelength_id_wavelength_seq'::regclass);


--
-- Name: alarm_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alarm_levels
    ADD CONSTRAINT alarm_levels_pkey PRIMARY KEY (id_alarm_level);


--
-- Name: alarm_trace_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alarm_trace
    ADD CONSTRAINT alarm_trace_pkey PRIMARY KEY (id_alarm_trace);


--
-- Name: alfa_compare_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alfa_compare
    ADD CONSTRAINT alfa_compare_pkey PRIMARY KEY (id_alfa_compare);


--
-- Name: fib_segm_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY fib_segm_data
    ADD CONSTRAINT fib_segm_data_pkey PRIMARY KEY (id_fib_segm);


--
-- Name: fiber_segments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY fiber_segments
    ADD CONSTRAINT fiber_segments_pkey PRIMARY KEY (id_fiber_segments);


--
-- Name: last_trace_id_fiber_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY last_trace
    ADD CONSTRAINT last_trace_id_fiber_key UNIQUE (id_fiber);


--
-- Name: last_trace_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY last_trace
    ADD CONSTRAINT last_trace_pkey PRIMARY KEY (id_last_trace);


--
-- Name: otdr_imei_unique; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY otdr
    ADD CONSTRAINT otdr_imei_unique UNIQUE (otdr_imei);


--
-- Name: pk_alarm; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alarm
    ADD CONSTRAINT pk_alarm PRIMARY KEY (id_alarm);


--
-- Name: pk_attenuation; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY attenuation
    ADD CONSTRAINT pk_attenuation PRIMARY KEY (id_attenuation);


--
-- Name: pk_cable; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cable
    ADD CONSTRAINT pk_cable PRIMARY KEY (id_cable);


--
-- Name: pk_fiber; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY fiber
    ADD CONSTRAINT pk_fiber PRIMARY KEY (id_fiber);


--
-- Name: pk_map_value; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY map_value
    ADD CONSTRAINT pk_map_value PRIMARY KEY (id_map_value);


--
-- Name: pk_new_peak; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY new_peak
    ADD CONSTRAINT pk_new_peak PRIMARY KEY (id_new_peak);


--
-- Name: pk_optic_users; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY optic_users
    ADD CONSTRAINT pk_optic_users PRIMARY KEY (id_user);


--
-- Name: pk_otdr; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY otdr
    ADD CONSTRAINT pk_otdr PRIMARY KEY (id_otdr);


--
-- Name: pk_pulse_duration; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pulse_duration
    ADD CONSTRAINT pk_pulse_duration PRIMARY KEY (id_pulse_duration);


--
-- Name: pk_rangeoflength; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rangeoflength
    ADD CONSTRAINT pk_rangeoflength PRIMARY KEY (id_range_of_length);


--
-- Name: pk_reference_trace; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reference_trace
    ADD CONSTRAINT pk_reference_trace PRIMARY KEY (id_trace);


--
-- Name: pk_system; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY system
    ADD CONSTRAINT pk_system PRIMARY KEY (id_system);


--
-- Name: pk_systemlog; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY systemlog
    ADD CONSTRAINT pk_systemlog PRIMARY KEY (id_systemlog);


--
-- Name: pk_test; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY test
    ADD CONSTRAINT pk_test PRIMARY KEY (id_test);


--
-- Name: pk_time_accum; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY time_accum
    ADD CONSTRAINT pk_time_accum PRIMARY KEY (id_time_occum);


--
-- Name: pk_trace; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY trace
    ADD CONSTRAINT pk_trace PRIMARY KEY (id_trace);


--
-- Name: pk_wavelength; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wavelength
    ADD CONSTRAINT pk_wavelength PRIMARY KEY (id_wavelength);


--
-- Name: reference_dots_id_fiber_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reference_dots
    ADD CONSTRAINT reference_dots_id_fiber_key UNIQUE (id_fiber);


--
-- Name: reference_dots_id_reference_dots_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reference_dots
    ADD CONSTRAINT reference_dots_id_reference_dots_key UNIQUE (id_reference_dots);


--
-- Name: reference_dots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reference_dots
    ADD CONSTRAINT reference_dots_pkey PRIMARY KEY (id_reference_dots);


--
-- Name: schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (id_schedule);


--
-- Name: segments_alfas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY segments_alfas
    ADD CONSTRAINT segments_alfas_pkey PRIMARY KEY (id_segments_alfas);


--
-- Name: sumb_compare_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sumb_compare
    ADD CONSTRAINT sumb_compare_pkey PRIMARY KEY (id_sumb_compare);


--
-- Name: urgent_action_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY urgent_action
    ADD CONSTRAINT urgent_action_pkey PRIMARY KEY (id_urgent_action);


--
-- Name: INDEX alarm_levels_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX alarm_levels_pkey IS '{0,0}';


--
-- Name: INDEX alarm_trace_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX alarm_trace_pkey IS '{0,0}';


--
-- Name: INDEX alfa_compare_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX alfa_compare_pkey IS '{0,0}';


--
-- Name: INDEX fib_segm_data_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX fib_segm_data_pkey IS '{0,0}';


--
-- Name: INDEX fiber_segments_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX fiber_segments_pkey IS '{0,0}';


--
-- Name: ind_alfa_compare_id_trace; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX ind_alfa_compare_id_trace ON alfa_compare USING btree (id_trace);


--
-- Name: INDEX ind_alfa_compare_id_trace; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX ind_alfa_compare_id_trace IS '{0,0}';


--
-- Name: ind_segments_alfas_id_fiber_segments; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX ind_segments_alfas_id_fiber_segments ON segments_alfas USING btree (id_fiber_segments);


--
-- Name: INDEX ind_segments_alfas_id_fiber_segments; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX ind_segments_alfas_id_fiber_segments IS '{0,0}';


--
-- Name: ind_sumb_compare_id_trace; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX ind_sumb_compare_id_trace ON sumb_compare USING btree (id_trace);


--
-- Name: INDEX ind_sumb_compare_id_trace; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX ind_sumb_compare_id_trace IS '{0,0}';


--
-- Name: ind_trace_trace_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX ind_trace_trace_date ON trace USING btree (trace_date);


--
-- Name: INDEX ind_trace_trace_date; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX ind_trace_trace_date IS '{0,0}';


--
-- Name: INDEX last_trace_id_fiber_key; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX last_trace_id_fiber_key IS '{0,0}';


--
-- Name: INDEX last_trace_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX last_trace_pkey IS '{0,0}';


--
-- Name: INDEX otdr_imei_unique; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX otdr_imei_unique IS '{0,0}';


--
-- Name: INDEX pk_alarm; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_alarm IS '{0,0}';


--
-- Name: INDEX pk_attenuation; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_attenuation IS '{0,0}';


--
-- Name: INDEX pk_cable; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_cable IS '{0,0}';


--
-- Name: INDEX pk_fiber; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_fiber IS '{0,0}';


--
-- Name: INDEX pk_map_value; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_map_value IS '{0,0}';


--
-- Name: INDEX pk_new_peak; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_new_peak IS '{0,0}';


--
-- Name: INDEX pk_optic_users; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_optic_users IS '{0,0}';


--
-- Name: INDEX pk_otdr; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_otdr IS '{0,0}';


--
-- Name: INDEX pk_pulse_duration; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_pulse_duration IS '{0,0}';


--
-- Name: INDEX pk_rangeoflength; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_rangeoflength IS '{0,0}';


--
-- Name: INDEX pk_reference_trace; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_reference_trace IS '{0,0}';


--
-- Name: INDEX pk_system; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_system IS '{0,0}';


--
-- Name: INDEX pk_systemlog; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_systemlog IS '{0,0}';


--
-- Name: INDEX pk_test; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_test IS '{0,0}';


--
-- Name: INDEX pk_time_accum; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_time_accum IS '{0,0}';


--
-- Name: INDEX pk_trace; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_trace IS '{0,0}';


--
-- Name: INDEX pk_wavelength; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX pk_wavelength IS '{0,0}';


--
-- Name: INDEX reference_dots_id_fiber_key; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX reference_dots_id_fiber_key IS '{0,0}';


--
-- Name: INDEX reference_dots_id_reference_dots_key; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX reference_dots_id_reference_dots_key IS '{0,0}';


--
-- Name: INDEX reference_dots_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX reference_dots_pkey IS '{0,0}';


--
-- Name: INDEX schedule_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX schedule_pkey IS '{0,0}';


--
-- Name: INDEX segments_alfas_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX segments_alfas_pkey IS '{0,0}';


--
-- Name: INDEX sumb_compare_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX sumb_compare_pkey IS '{0,0}';


--
-- Name: INDEX urgent_action_pkey; Type: MAC LABEL; Schema: public; Owner: postgres
--

MAC LABEL ON INDEX urgent_action_pkey IS '{0,0}';


--
-- Name: fk_alarm_reference_optic_us; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alarm
    ADD CONSTRAINT fk_alarm_reference_optic_us FOREIGN KEY (id_user) REFERENCES optic_users(id_user) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_fiber_reference_otdr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fiber
    ADD CONSTRAINT fk_fiber_reference_otdr FOREIGN KEY (id_otdr) REFERENCES otdr(id_otdr) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: fk_fiber_segments; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fib_segm_data
    ADD CONSTRAINT fk_fiber_segments FOREIGN KEY (id_fiber_segments) REFERENCES fiber_segments(id_fiber_segments) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: fk_id_alarm_trace; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alarm
    ADD CONSTRAINT fk_id_alarm_trace FOREIGN KEY (id_alarm_trace) REFERENCES alarm_trace(id_alarm_trace) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_id_alarm_trace; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alfa_compare
    ADD CONSTRAINT fk_id_alarm_trace FOREIGN KEY (id_trace) REFERENCES alarm_trace(id_alarm_trace) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_id_alarm_trace; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sumb_compare
    ADD CONSTRAINT fk_id_alarm_trace FOREIGN KEY (id_trace) REFERENCES alarm_trace(id_alarm_trace) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_id_fiber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trace
    ADD CONSTRAINT fk_id_fiber FOREIGN KEY (id_fiber) REFERENCES fiber(id_fiber) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: fk_id_fiber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alarm
    ADD CONSTRAINT fk_id_fiber FOREIGN KEY (id_fiber) REFERENCES fiber(id_fiber) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: fk_id_fiber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY segments_alfas
    ADD CONSTRAINT fk_id_fiber FOREIGN KEY (id_fiber) REFERENCES fiber(id_fiber) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: fk_id_fiber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY last_trace
    ADD CONSTRAINT fk_id_fiber FOREIGN KEY (id_fiber) REFERENCES fiber(id_fiber) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: fk_id_fiber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alarm_trace
    ADD CONSTRAINT fk_id_fiber FOREIGN KEY (id_fiber) REFERENCES fiber(id_fiber) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_map_valu_reference_cable; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY map_value
    ADD CONSTRAINT fk_map_valu_reference_cable FOREIGN KEY (id_cable) REFERENCES cable(id_cable) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_pulse_du_reference_otdr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pulse_duration
    ADD CONSTRAINT fk_pulse_du_reference_otdr FOREIGN KEY (id_otdr) REFERENCES otdr(id_otdr) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: fk_rangeofl_reference_otdr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rangeoflength
    ADD CONSTRAINT fk_rangeofl_reference_otdr FOREIGN KEY (id_otdr) REFERENCES otdr(id_otdr) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: fk_referenc_reference_fiber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reference_trace
    ADD CONSTRAINT fk_referenc_reference_fiber FOREIGN KEY (id_fiber) REFERENCES fiber(id_fiber) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_segments_alfas_reference_id_fiber_segments; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY segments_alfas
    ADD CONSTRAINT fk_segments_alfas_reference_id_fiber_segments FOREIGN KEY (id_fiber_segments) REFERENCES fiber_segments(id_fiber_segments) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fk_systemlo_reference_optic_us; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY systemlog
    ADD CONSTRAINT fk_systemlo_reference_optic_us FOREIGN KEY (id_user) REFERENCES optic_users(id_user) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_test_reference_fiber; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY test
    ADD CONSTRAINT fk_test_reference_fiber FOREIGN KEY (id_fiber) REFERENCES fiber(id_fiber) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_time_acc_reference_otdr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY time_accum
    ADD CONSTRAINT fk_time_acc_reference_otdr FOREIGN KEY (id_otdr) REFERENCES otdr(id_otdr) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: fk_trace_reference_alarm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trace
    ADD CONSTRAINT fk_trace_reference_alarm FOREIGN KEY (id_alarm) REFERENCES alarm(id_alarm) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_trace_reference_optic_us; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trace
    ADD CONSTRAINT fk_trace_reference_optic_us FOREIGN KEY (id_user) REFERENCES optic_users(id_user) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_waveleng_reference_otdr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wavelength
    ADD CONSTRAINT fk_waveleng_reference_otdr FOREIGN KEY (id_otdr) REFERENCES otdr(id_otdr) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: reference_dots_id_fiber_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reference_dots
    ADD CONSTRAINT reference_dots_id_fiber_fkey FOREIGN KEY (id_fiber) REFERENCES fiber(id_fiber);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: alarm_levels; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE alarm_levels FROM PUBLIC;
REVOKE ALL ON TABLE alarm_levels FROM postgres;
GRANT ALL ON TABLE alarm_levels TO postgres;
GRANT ALL ON TABLE alarm_levels TO webuser;


--
-- Name: alarm_levels_id_alarm_level_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE alarm_levels_id_alarm_level_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE alarm_levels_id_alarm_level_seq FROM postgres;
GRANT ALL ON SEQUENCE alarm_levels_id_alarm_level_seq TO postgres;
GRANT ALL ON SEQUENCE alarm_levels_id_alarm_level_seq TO webuser;


--
-- Name: alfa_compare; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE alfa_compare FROM PUBLIC;
REVOKE ALL ON TABLE alfa_compare FROM postgres;
GRANT ALL ON TABLE alfa_compare TO postgres;
GRANT ALL ON TABLE alfa_compare TO webuser;


--
-- Name: alfa_compare_id_alfa_compare_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE alfa_compare_id_alfa_compare_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE alfa_compare_id_alfa_compare_seq FROM postgres;
GRANT ALL ON SEQUENCE alfa_compare_id_alfa_compare_seq TO postgres;
GRANT ALL ON SEQUENCE alfa_compare_id_alfa_compare_seq TO webuser;


--
-- Name: attenuation; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE attenuation FROM PUBLIC;
REVOKE ALL ON TABLE attenuation FROM postgres;
GRANT ALL ON TABLE attenuation TO postgres;
GRANT ALL ON TABLE attenuation TO webuser;


--
-- Name: attenuation_id_attenuation_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE attenuation_id_attenuation_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE attenuation_id_attenuation_seq FROM postgres;
GRANT ALL ON SEQUENCE attenuation_id_attenuation_seq TO postgres;
GRANT ALL ON SEQUENCE attenuation_id_attenuation_seq TO webuser;


--
-- Name: cable; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE cable FROM PUBLIC;
REVOKE ALL ON TABLE cable FROM postgres;
GRANT ALL ON TABLE cable TO postgres;
GRANT ALL ON TABLE cable TO webuser;


--
-- Name: cable_id_cable_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE cable_id_cable_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cable_id_cable_seq FROM postgres;
GRANT ALL ON SEQUENCE cable_id_cable_seq TO postgres;
GRANT ALL ON SEQUENCE cable_id_cable_seq TO webuser;


--
-- Name: debug; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE debug FROM PUBLIC;
REVOKE ALL ON TABLE debug FROM postgres;
GRANT ALL ON TABLE debug TO postgres;
GRANT ALL ON TABLE debug TO webuser;


--
-- Name: fiber; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE fiber FROM PUBLIC;
REVOKE ALL ON TABLE fiber FROM postgres;
GRANT ALL ON TABLE fiber TO postgres;
GRANT ALL ON TABLE fiber TO webuser;


--
-- Name: fiber_id_fiber_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE fiber_id_fiber_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE fiber_id_fiber_seq FROM postgres;
GRANT ALL ON SEQUENCE fiber_id_fiber_seq TO postgres;
GRANT ALL ON SEQUENCE fiber_id_fiber_seq TO webuser;


--
-- Name: fiber_segments; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE fiber_segments FROM PUBLIC;
REVOKE ALL ON TABLE fiber_segments FROM postgres;
GRANT ALL ON TABLE fiber_segments TO postgres;
GRANT ALL ON TABLE fiber_segments TO webuser;


--
-- Name: fiber_segments_id_fiber_segments_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE fiber_segments_id_fiber_segments_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE fiber_segments_id_fiber_segments_seq FROM postgres;
GRANT ALL ON SEQUENCE fiber_segments_id_fiber_segments_seq TO postgres;
GRANT ALL ON SEQUENCE fiber_segments_id_fiber_segments_seq TO webuser;


--
-- Name: map_value; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE map_value FROM PUBLIC;
REVOKE ALL ON TABLE map_value FROM postgres;
GRANT ALL ON TABLE map_value TO postgres;
GRANT ALL ON TABLE map_value TO webuser;


--
-- Name: map_value_id_map_value_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE map_value_id_map_value_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE map_value_id_map_value_seq FROM postgres;
GRANT ALL ON SEQUENCE map_value_id_map_value_seq TO postgres;
GRANT ALL ON SEQUENCE map_value_id_map_value_seq TO webuser;


--
-- Name: migrations; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE migrations FROM PUBLIC;
REVOKE ALL ON TABLE migrations FROM postgres;
GRANT ALL ON TABLE migrations TO postgres;
GRANT ALL ON TABLE migrations TO webuser;


--
-- Name: new_peak; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE new_peak FROM PUBLIC;
REVOKE ALL ON TABLE new_peak FROM postgres;
GRANT ALL ON TABLE new_peak TO postgres;
GRANT ALL ON TABLE new_peak TO webuser;


--
-- Name: new_peak_id_new_peak_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE new_peak_id_new_peak_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE new_peak_id_new_peak_seq FROM postgres;
GRANT ALL ON SEQUENCE new_peak_id_new_peak_seq TO postgres;
GRANT ALL ON SEQUENCE new_peak_id_new_peak_seq TO webuser;


--
-- Name: optic_users; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE optic_users FROM PUBLIC;
REVOKE ALL ON TABLE optic_users FROM postgres;
GRANT ALL ON TABLE optic_users TO postgres;
GRANT ALL ON TABLE optic_users TO webuser;


--
-- Name: optic_users_id_user_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE optic_users_id_user_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE optic_users_id_user_seq FROM postgres;
GRANT ALL ON SEQUENCE optic_users_id_user_seq TO postgres;
GRANT ALL ON SEQUENCE optic_users_id_user_seq TO webuser;


--
-- Name: otdr; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE otdr FROM PUBLIC;
REVOKE ALL ON TABLE otdr FROM postgres;
GRANT ALL ON TABLE otdr TO postgres;
GRANT ALL ON TABLE otdr TO webuser;


--
-- Name: otdr_id_otdr_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE otdr_id_otdr_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE otdr_id_otdr_seq FROM postgres;
GRANT ALL ON SEQUENCE otdr_id_otdr_seq TO postgres;
GRANT ALL ON SEQUENCE otdr_id_otdr_seq TO webuser;


--
-- Name: pulse_duration; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE pulse_duration FROM PUBLIC;
REVOKE ALL ON TABLE pulse_duration FROM postgres;
GRANT ALL ON TABLE pulse_duration TO postgres;
GRANT ALL ON TABLE pulse_duration TO webuser;


--
-- Name: pulse_duration_id_pulse_duration_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE pulse_duration_id_pulse_duration_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE pulse_duration_id_pulse_duration_seq FROM postgres;
GRANT ALL ON SEQUENCE pulse_duration_id_pulse_duration_seq TO postgres;
GRANT ALL ON SEQUENCE pulse_duration_id_pulse_duration_seq TO webuser;


--
-- Name: rangeoflength; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE rangeoflength FROM PUBLIC;
REVOKE ALL ON TABLE rangeoflength FROM postgres;
GRANT ALL ON TABLE rangeoflength TO postgres;
GRANT ALL ON TABLE rangeoflength TO webuser;


--
-- Name: rangeoflength_id_range_of_length_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE rangeoflength_id_range_of_length_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE rangeoflength_id_range_of_length_seq FROM postgres;
GRANT ALL ON SEQUENCE rangeoflength_id_range_of_length_seq TO postgres;
GRANT ALL ON SEQUENCE rangeoflength_id_range_of_length_seq TO webuser;


--
-- Name: reference_trace; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE reference_trace FROM PUBLIC;
REVOKE ALL ON TABLE reference_trace FROM postgres;
GRANT ALL ON TABLE reference_trace TO postgres;
GRANT ALL ON TABLE reference_trace TO webuser;


--
-- Name: reference_trace_id_trace_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE reference_trace_id_trace_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE reference_trace_id_trace_seq FROM postgres;
GRANT ALL ON SEQUENCE reference_trace_id_trace_seq TO postgres;
GRANT ALL ON SEQUENCE reference_trace_id_trace_seq TO webuser;


--
-- Name: schedule; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE schedule FROM PUBLIC;
REVOKE ALL ON TABLE schedule FROM postgres;
GRANT ALL ON TABLE schedule TO postgres;
GRANT ALL ON TABLE schedule TO webuser;


--
-- Name: schedule_id_schedule_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE schedule_id_schedule_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE schedule_id_schedule_seq FROM postgres;
GRANT ALL ON SEQUENCE schedule_id_schedule_seq TO postgres;
GRANT ALL ON SEQUENCE schedule_id_schedule_seq TO webuser;


--
-- Name: segments_alfas; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE segments_alfas FROM PUBLIC;
REVOKE ALL ON TABLE segments_alfas FROM postgres;
GRANT ALL ON TABLE segments_alfas TO postgres;
GRANT ALL ON TABLE segments_alfas TO webuser;


--
-- Name: segments_alfas_id_segments_alfas_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE segments_alfas_id_segments_alfas_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE segments_alfas_id_segments_alfas_seq FROM postgres;
GRANT ALL ON SEQUENCE segments_alfas_id_segments_alfas_seq TO postgres;
GRANT ALL ON SEQUENCE segments_alfas_id_segments_alfas_seq TO webuser;


--
-- Name: system; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE system FROM PUBLIC;
REVOKE ALL ON TABLE system FROM postgres;
GRANT ALL ON TABLE system TO postgres;
GRANT ALL ON TABLE system TO webuser;


--
-- Name: system_id_system_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE system_id_system_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE system_id_system_seq FROM postgres;
GRANT ALL ON SEQUENCE system_id_system_seq TO postgres;
GRANT ALL ON SEQUENCE system_id_system_seq TO webuser;


--
-- Name: systemlog; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE systemlog FROM PUBLIC;
REVOKE ALL ON TABLE systemlog FROM postgres;
GRANT ALL ON TABLE systemlog TO postgres;
GRANT ALL ON TABLE systemlog TO webuser;


--
-- Name: systemlog_id_systemlog_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE systemlog_id_systemlog_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE systemlog_id_systemlog_seq FROM postgres;
GRANT ALL ON SEQUENCE systemlog_id_systemlog_seq TO postgres;
GRANT ALL ON SEQUENCE systemlog_id_systemlog_seq TO webuser;


--
-- Name: test; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE test FROM PUBLIC;
REVOKE ALL ON TABLE test FROM postgres;
GRANT ALL ON TABLE test TO postgres;
GRANT ALL ON TABLE test TO webuser;


--
-- Name: test_id_test_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE test_id_test_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE test_id_test_seq FROM postgres;
GRANT ALL ON SEQUENCE test_id_test_seq TO postgres;
GRANT ALL ON SEQUENCE test_id_test_seq TO webuser;


--
-- Name: time_accum; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE time_accum FROM PUBLIC;
REVOKE ALL ON TABLE time_accum FROM postgres;
GRANT ALL ON TABLE time_accum TO postgres;
GRANT ALL ON TABLE time_accum TO webuser;


--
-- Name: time_accum_id_time_occum_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE time_accum_id_time_occum_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE time_accum_id_time_occum_seq FROM postgres;
GRANT ALL ON SEQUENCE time_accum_id_time_occum_seq TO postgres;
GRANT ALL ON SEQUENCE time_accum_id_time_occum_seq TO webuser;


--
-- Name: trace; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE trace FROM PUBLIC;
REVOKE ALL ON TABLE trace FROM postgres;
GRANT ALL ON TABLE trace TO postgres;
GRANT ALL ON TABLE trace TO webuser;


--
-- Name: trace_id_trace_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE trace_id_trace_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE trace_id_trace_seq FROM postgres;
GRANT ALL ON SEQUENCE trace_id_trace_seq TO postgres;
GRANT ALL ON SEQUENCE trace_id_trace_seq TO webuser;


--
-- Name: urgent_action; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE urgent_action FROM PUBLIC;
REVOKE ALL ON TABLE urgent_action FROM postgres;
GRANT ALL ON TABLE urgent_action TO postgres;
GRANT ALL ON TABLE urgent_action TO webuser;


--
-- Name: urgent_action_id_urgent_action_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE urgent_action_id_urgent_action_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE urgent_action_id_urgent_action_seq FROM postgres;
GRANT ALL ON SEQUENCE urgent_action_id_urgent_action_seq TO postgres;
GRANT ALL ON SEQUENCE urgent_action_id_urgent_action_seq TO webuser;


--
-- Name: wavelength; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE wavelength FROM PUBLIC;
REVOKE ALL ON TABLE wavelength FROM postgres;
GRANT ALL ON TABLE wavelength TO postgres;
GRANT ALL ON TABLE wavelength TO webuser;


--
-- Name: wavelength_id_wavelength_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE wavelength_id_wavelength_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE wavelength_id_wavelength_seq FROM postgres;
GRANT ALL ON SEQUENCE wavelength_id_wavelength_seq TO postgres;
GRANT ALL ON SEQUENCE wavelength_id_wavelength_seq TO webuser;


--
-- PostgreSQL database dump complete
--

