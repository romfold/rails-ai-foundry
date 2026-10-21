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

--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


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
-- Name: knowledge_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_documents (
    id bigint NOT NULL,
    tenant_id character varying NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    source_key character varying,
    lock_version integer DEFAULT 0 NOT NULL
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
-- Name: knowledge_passages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_passages (
    id bigint NOT NULL,
    document_id bigint NOT NULL,
    version character varying NOT NULL,
    ordinal integer NOT NULL,
    body text NOT NULL,
    embedding public.vector(1536) NOT NULL,
    document_revision integer DEFAULT 0 NOT NULL
);


--
-- Name: knowledge_passages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_passages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_passages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_passages_id_seq OWNED BY public.knowledge_passages.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: knowledge_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_documents ALTER COLUMN id SET DEFAULT nextval('public.knowledge_documents_id_seq'::regclass);


--
-- Name: knowledge_passages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_passages ALTER COLUMN id SET DEFAULT nextval('public.knowledge_passages_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: knowledge_documents knowledge_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_documents
    ADD CONSTRAINT knowledge_documents_pkey PRIMARY KEY (id);


--
-- Name: knowledge_passages knowledge_passages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_passages
    ADD CONSTRAINT knowledge_passages_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: idx_on_document_id_version_ordinal_bc2f75fa73; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_document_id_version_ordinal_bc2f75fa73 ON public.knowledge_passages USING btree (document_id, version, ordinal);


--
-- Name: index_knowledge_documents_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_documents_on_tenant_id ON public.knowledge_documents USING btree (tenant_id);


--
-- Name: index_knowledge_documents_on_tenant_id_and_source_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_knowledge_documents_on_tenant_id_and_source_key ON public.knowledge_documents USING btree (tenant_id, source_key);


--
-- Name: index_knowledge_passages_on_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledge_passages_on_document_id ON public.knowledge_passages USING btree (document_id);


--
-- Name: knowledge_passages_embedding_hnsw; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX knowledge_passages_embedding_hnsw ON public.knowledge_passages USING hnsw (embedding public.vector_cosine_ops);


--
-- Name: knowledge_passages fk_rails_d7081cf574; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_passages
    ADD CONSTRAINT fk_rails_d7081cf574 FOREIGN KEY (document_id) REFERENCES public.knowledge_documents(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260916000100'),
('20260909010000');

