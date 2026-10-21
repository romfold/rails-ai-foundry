SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: knowledge_collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_collections (
    id bigint NOT NULL,
    tenant_id character varying,
    name character varying NOT NULL
);


--
-- Name: knowledge_collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_collections_id_seq OWNED BY public.knowledge_collections.id;


--
-- Name: knowledge_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_documents (
    id bigint NOT NULL,
    collection_id bigint NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    revision integer DEFAULT 1 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tenant_id character varying,
    CONSTRAINT knowledge_tenant_present CHECK ((tenant_id IS NOT NULL))
);


--
-- Name: knowledge_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_documents_id_seq OWNED BY public.knowledge_documents.id;


--
-- Name: knowledge_tenant_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_tenant_issues (
    document_id bigint NOT NULL,
    reason character varying NOT NULL
);


--
-- Name: knowledge_tenant_issues_document_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_tenant_issues_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_tenant_issues_document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_tenant_issues_document_id_seq OWNED BY public.knowledge_tenant_issues.document_id;


--
-- Name: knowledge_tenant_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_tenant_migrations (
    id bigint NOT NULL,
    phase character varying DEFAULT 'expanded'::character varying NOT NULL,
    cursor bigint DEFAULT 0 NOT NULL,
    scan_bound bigint DEFAULT 0 NOT NULL,
    active boolean DEFAULT false NOT NULL,
    writers_confirmed_at timestamp(6) without time zone,
    CONSTRAINT one_tenant_migration CHECK ((id = 1))
);


--
-- Name: knowledge_tenant_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_tenant_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_tenant_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_tenant_migrations_id_seq OWNED BY public.knowledge_tenant_migrations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: knowledge_collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_collections ALTER COLUMN id SET DEFAULT nextval('public.knowledge_collections_id_seq'::regclass);


--
-- Name: knowledge_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_documents ALTER COLUMN id SET DEFAULT nextval('public.knowledge_documents_id_seq'::regclass);


--
-- Name: knowledge_tenant_issues document_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_tenant_issues ALTER COLUMN document_id SET DEFAULT nextval('public.knowledge_tenant_issues_document_id_seq'::regclass);


--
-- Name: knowledge_tenant_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_tenant_migrations ALTER COLUMN id SET DEFAULT nextval('public.knowledge_tenant_migrations_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: knowledge_collections knowledge_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_collections
    ADD CONSTRAINT knowledge_collections_pkey PRIMARY KEY (id);


--
-- Name: knowledge_documents knowledge_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_documents
    ADD CONSTRAINT knowledge_documents_pkey PRIMARY KEY (id);


--
-- Name: knowledge_tenant_issues knowledge_tenant_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_tenant_issues
    ADD CONSTRAINT knowledge_tenant_issues_pkey PRIMARY KEY (document_id);


--
-- Name: knowledge_tenant_migrations knowledge_tenant_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_tenant_migrations
    ADD CONSTRAINT knowledge_tenant_migrations_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_knowledge_collections_on_id_and_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_knowledge_collections_on_id_and_tenant_id ON public.knowledge_collections USING btree (id, tenant_id);


--
-- Name: index_knowledge_documents_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_documents_on_collection_id ON public.knowledge_documents USING btree (collection_id);


--
-- Name: index_knowledge_documents_on_tenant_id_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_documents_on_tenant_id_and_id ON public.knowledge_documents USING btree (tenant_id, id);


--
-- Name: knowledge_documents fk_rails_f24d11156f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_documents
    ADD CONSTRAINT fk_rails_f24d11156f FOREIGN KEY (collection_id) REFERENCES public.knowledge_collections(id);


--
-- Name: knowledge_documents knowledge_collection_owner; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_documents
    ADD CONSTRAINT knowledge_collection_owner FOREIGN KEY (collection_id, tenant_id) REFERENCES public.knowledge_collections(id, tenant_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260924000002'),
('20260924000001');

