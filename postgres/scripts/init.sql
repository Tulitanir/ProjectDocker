--
-- TOC entry 242 (class 1255 OID 25370)
-- Name: get_training_by_trainer_date(bigint, date, time without time zone, time without time zone); Type: FUNCTION; Schema: public; Owner: test
--

CREATE FUNCTION public.get_training_by_trainer_date(trainer_id bigint, date_ date, beginning_time time without time zone, end_time time without time zone) RETURNS TABLE(training_id bigint, trainerid bigint, training_date date, beginning_t time without time zone, end_t time without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
    SELECT id, trainer, date, beginning, "end"
    FROM training_trainer
    WHERE trainer = trainer_id
      AND date = date_
      AND "end" > beginning_time
      AND beginning < end_time;
END;
$$;

--
-- TOC entry 241 (class 1255 OID 25306)
-- Name: get_training_member_count(); Type: FUNCTION; Schema: public; Owner: test
--

CREATE FUNCTION public.get_training_member_count() RETURNS TABLE(training_id bigint, member_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t.id AS id, COUNT(mt.training) AS member_count
    FROM trainings t
    LEFT JOIN member_training mt ON t.id = mt.training
    GROUP BY t.id;
END;
$$;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 25009)
-- Name: comment; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.comment (
    id bigint NOT NULL,
    "time" timestamp without time zone DEFAULT now() NOT NULL,
    text character varying NOT NULL,
    member_id bigint NOT NULL,
    news_id bigint NOT NULL,
    is_changed boolean DEFAULT false NOT NULL
);

--
-- TOC entry 229 (class 1259 OID 25008)
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.comment ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 16745)
-- Name: duty; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.duty (
    id bigint NOT NULL,
    place_id bigint NOT NULL,
    start timestamp without time zone DEFAULT now() NOT NULL,
    "end" timestamp without time zone DEFAULT now() NOT NULL
);

--
-- TOC entry 225 (class 1259 OID 16744)
-- Name: duty_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.duty ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.duty_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 215 (class 1259 OID 16456)
-- Name: member; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.member (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    patronymic character varying(50),
    phone character varying(20) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    image character varying
);

--
-- TOC entry 214 (class 1259 OID 16455)
-- Name: member_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.member ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 217 (class 1259 OID 16462)
-- Name: role; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.role (
    id bigint NOT NULL,
    name character varying(50) NOT NULL
);

--
-- TOC entry 227 (class 1259 OID 16750)
-- Name: role_binding; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.role_binding (
    id bigint NOT NULL,
    member bigint NOT NULL,
    role bigint NOT NULL
);

--
-- TOC entry 233 (class 1259 OID 25316)
-- Name: member_role; Type: VIEW; Schema: public; Owner: test
--

CREATE VIEW public.member_role AS
 SELECT rb.member,
    rb.role AS role_id,
    r.name
   FROM (public.role_binding rb
     JOIN public.role r ON ((rb.role = r.id)));

--
-- TOC entry 238 (class 1259 OID 25335)
-- Name: subscription; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.subscription (
    id bigint NOT NULL,
    member bigint NOT NULL,
    option bigint NOT NULL,
    date date DEFAULT now() NOT NULL
);

--
-- TOC entry 236 (class 1259 OID 25326)
-- Name: subscription_option; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.subscription_option (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    duration smallint NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    price smallint DEFAULT 1000 NOT NULL
);

--
-- TOC entry 239 (class 1259 OID 25351)
-- Name: member_subscription; Type: VIEW; Schema: public; Owner: test
--

CREATE VIEW public.member_subscription AS
 SELECT member.id,
    member.name,
    member.surname,
    member.patronymic,
    member.phone,
    member.email,
    member.password,
    member.is_active,
    member.image,
    (subscription.date + ('1 day'::interval * (subscription_option.duration)::double precision)) AS expiration_date
   FROM ((public.member
     LEFT JOIN public.subscription ON ((subscription.member = member.id)))
     LEFT JOIN public.subscription_option ON ((subscription.option = subscription_option.id)));

--
-- TOC entry 222 (class 1259 OID 16661)
-- Name: member_training; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.member_training (
    member bigint NOT NULL,
    training bigint NOT NULL,
    id bigint NOT NULL
);

--
-- TOC entry 240 (class 1259 OID 25373)
-- Name: member_training_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.member_training ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.member_training_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 16585)
-- Name: news; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.news (
    id bigint NOT NULL,
    title text NOT NULL,
    text text NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    is_changed boolean DEFAULT false NOT NULL
);

--
-- TOC entry 220 (class 1259 OID 16584)
-- Name: news_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.news ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

INSERT INTO public.news(title, text, date) VALUES('Тестовая новость', 'Текст тестовой новости', '01.01.24');


--
-- TOC entry 219 (class 1259 OID 16500)
-- Name: program; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.program (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    description character varying NOT NULL
);

--
-- TOC entry 218 (class 1259 OID 16499)
-- Name: program_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.program ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.program_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 24970)
-- Name: role_binding_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.role_binding ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.role_binding_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 216 (class 1259 OID 16461)
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.role ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

INSERT INTO public.role(name) VALUES('member');
INSERT INTO public.role(name) VALUES('trainer');
INSERT INTO public.role(name) VALUES('admin');


--
-- TOC entry 237 (class 1259 OID 25334)
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 25325)
-- Name: subscription_option_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.subscription_option ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.subscription_option_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 16704)
-- Name: trainings; Type: TABLE; Schema: public; Owner: test
--

CREATE TABLE public.trainings (
    id bigint NOT NULL,
    program bigint NOT NULL,
    trainer bigint NOT NULL,
    date date NOT NULL,
    capacity smallint NOT NULL,
    beginning time without time zone NOT NULL,
    "end" time without time zone NOT NULL
);

--
-- TOC entry 234 (class 1259 OID 25320)
-- Name: training_trainer; Type: VIEW; Schema: public; Owner: test
--

CREATE VIEW public.training_trainer AS
 SELECT trainings.id,
    member.id AS trainer,
    member.name,
    member.surname,
    program.name AS title,
    trainings.beginning,
    trainings."end",
    trainings.date,
    trainings.capacity,
    member_count.member_count
   FROM (((public.trainings
     JOIN public.member ON ((trainings.trainer = member.id)))
     JOIN public.program ON ((program.id = trainings.program)))
     JOIN public.get_training_member_count() member_count(training_id, member_count) ON ((member_count.training_id = trainings.id)));

--
-- TOC entry 223 (class 1259 OID 16703)
-- Name: trainings_id_seq; Type: SEQUENCE; Schema: public; Owner: test
--

ALTER TABLE public.trainings ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.trainings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 25312)
-- Name: user_role; Type: VIEW; Schema: public; Owner: test
--

CREATE VIEW public.user_role AS
 SELECT m.id,
    m.name,
    m.surname,
    role.name AS role
   FROM ((public.member m
     JOIN public.role_binding rb ON ((m.id = rb.member)))
     JOIN public.role ON ((role.id = rb.role)));

--
-- TOC entry 231 (class 1259 OID 25296)
-- Name: view_comments; Type: VIEW; Schema: public; Owner: test
--

CREATE VIEW public.view_comments AS
 SELECT comment.id,
    comment.member_id,
    member.name,
    member.surname,
    comment.text,
    comment."time",
    comment.news_id,
    comment.is_changed
   FROM (public.comment
     LEFT JOIN public.member ON ((comment.member_id = member.id)));

--
-- TOC entry 3272 (class 2606 OID 25113)
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- TOC entry 3268 (class 2606 OID 25148)
-- Name: duty duty_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.duty
    ADD CONSTRAINT duty_pkey PRIMARY KEY (id);


--
-- TOC entry 3256 (class 2606 OID 25197)
-- Name: member member_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- TOC entry 3264 (class 2606 OID 25372)
-- Name: member_training member_training_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.member_training
    ADD CONSTRAINT member_training_pkey PRIMARY KEY (id);


--
-- TOC entry 3262 (class 2606 OID 25160)
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- TOC entry 3270 (class 2606 OID 25238)
-- Name: role_binding pk_role_binding; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.role_binding
    ADD CONSTRAINT pk_role_binding PRIMARY KEY (id);


--
-- TOC entry 3260 (class 2606 OID 25176)
-- Name: program program_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT program_pkey PRIMARY KEY (id);


--
-- TOC entry 3258 (class 2606 OID 25226)
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- TOC entry 3274 (class 2606 OID 25333)
-- Name: subscription_option subscription_option_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.subscription_option
    ADD CONSTRAINT subscription_option_pkey PRIMARY KEY (id);


--
-- TOC entry 3276 (class 2606 OID 25340)
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (id);


--
-- TOC entry 3266 (class 2606 OID 25263)
-- Name: trainings trainings_pkey; Type: CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_pkey PRIMARY KEY (id);


--
-- TOC entry 3277 (class 2606 OID 25198)
-- Name: member_training fk_binding_trainer; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.member_training
    ADD CONSTRAINT fk_binding_trainer FOREIGN KEY (member) REFERENCES public.member(id) MATCH FULL;


--
-- TOC entry 3278 (class 2606 OID 25264)
-- Name: member_training fk_binding_training; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.member_training
    ADD CONSTRAINT fk_binding_training FOREIGN KEY (training) REFERENCES public.trainings(id) MATCH FULL NOT VALID;


--
-- TOC entry 3283 (class 2606 OID 25203)
-- Name: comment fk_comment_member; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT fk_comment_member FOREIGN KEY (member_id) REFERENCES public.member(id) MATCH FULL;


--
-- TOC entry 3284 (class 2606 OID 25161)
-- Name: comment fk_comment_news; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT fk_comment_news FOREIGN KEY (news_id) REFERENCES public.news(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3281 (class 2606 OID 25243)
-- Name: role_binding fk_rb_member; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.role_binding
    ADD CONSTRAINT fk_rb_member FOREIGN KEY (member) REFERENCES public.member(id) MATCH FULL NOT VALID;


--
-- TOC entry 3282 (class 2606 OID 25252)
-- Name: role_binding fk_rb_role; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.role_binding
    ADD CONSTRAINT fk_rb_role FOREIGN KEY (role) REFERENCES public.role(id) MATCH FULL NOT VALID;


--
-- TOC entry 3285 (class 2606 OID 25341)
-- Name: subscription fk_sub_member; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT fk_sub_member FOREIGN KEY (member) REFERENCES public.member(id) MATCH FULL;


--
-- TOC entry 3286 (class 2606 OID 25346)
-- Name: subscription fk_sub_option; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT fk_sub_option FOREIGN KEY (option) REFERENCES public.subscription_option(id) MATCH FULL;


--
-- TOC entry 3279 (class 2606 OID 25273)
-- Name: trainings fk_trainings_program; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT fk_trainings_program FOREIGN KEY (program) REFERENCES public.program(id) MATCH FULL;


--
-- TOC entry 3280 (class 2606 OID 25282)
-- Name: trainings fk_trainings_trainer; Type: FK CONSTRAINT; Schema: public; Owner: test
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT fk_trainings_trainer FOREIGN KEY (trainer) REFERENCES public.member(id) MATCH FULL;


-- Completed on 2023-12-15 17:22:35

--
-- PostgreSQL database dump complete
--

