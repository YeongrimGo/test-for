--
-- PostgreSQL database dump
--

\restrict TbNJlOMKWXt2ECUW1qM7SdmuD9DiNr2Y3GhgFv6SC9piHwQ7fXQwTAh7HPxI2DG

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

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
-- Name: AuditActorType; Type: TYPE; Schema: public; Owner: devuser
--

CREATE TYPE public."AuditActorType" AS ENUM (
    'USER',
    'SYSTEM'
);


ALTER TYPE public."AuditActorType" OWNER TO devuser;

--
-- Name: ExceptionStatus; Type: TYPE; Schema: public; Owner: devuser
--

CREATE TYPE public."ExceptionStatus" AS ENUM (
    'PENDING',
    'APPLYING',
    'APPROVED',
    'REJECTED',
    'CANCELLING',
    'EXPIRING',
    'EXPIRED',
    'CANCELLED',
    'FAILED'
);


ALTER TYPE public."ExceptionStatus" OWNER TO devuser;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: devuser
--

CREATE TYPE public."Role" AS ENUM (
    'ADMIN',
    'APPROVER',
    'REQUESTER',
    'VIEWER'
);


ALTER TYPE public."Role" OWNER TO devuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AuditLog; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."AuditLog" (
    id text NOT NULL,
    action character varying(100) NOT NULL,
    "entityType" character varying(100) NOT NULL,
    "entityId" text NOT NULL,
    "actorType" public."AuditActorType" NOT NULL,
    "beforeStatus" public."ExceptionStatus",
    "afterStatus" public."ExceptionStatus",
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text
);


ALTER TABLE public."AuditLog" OWNER TO devuser;

--
-- Name: Notification; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."Notification" (
    id text NOT NULL,
    title character varying(253) NOT NULL,
    message character varying(2000) NOT NULL,
    type character varying(50) NOT NULL,
    severity character varying(50) NOT NULL,
    href character varying(512) NOT NULL,
    "targetRoles" public."Role"[],
    "targetUserEmails" text[],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Notification" OWNER TO devuser;

--
-- Name: NotificationRead; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."NotificationRead" (
    "userId" text NOT NULL,
    "notificationId" character varying(128) NOT NULL,
    "readAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."NotificationRead" OWNER TO devuser;

--
-- Name: Permission; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."Permission" (
    id text NOT NULL,
    key text NOT NULL,
    description text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Permission" OWNER TO devuser;

--
-- Name: PolicyExceptionRequest; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."PolicyExceptionRequest" (
    id text NOT NULL,
    status public."ExceptionStatus" DEFAULT 'PENDING'::public."ExceptionStatus" NOT NULL,
    reason character varying(2000) NOT NULL,
    "policyName" character varying(253) NOT NULL,
    "ruleNames" text[],
    "appliedRuleNames" text[] DEFAULT ARRAY[]::text[],
    "resourceKind" character varying(63) NOT NULL,
    "resourceName" character varying(253) NOT NULL,
    "resourceNamespace" character varying(63),
    "targetClusterId" character varying(128) NOT NULL,
    "targetClusterDisplayName" character varying(253) NOT NULL,
    "k8sExceptionName" character varying(253) NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "decisionNote" character varying(2000),
    "decidedAt" timestamp(3) without time zone,
    "activatedAt" timestamp(3) without time zone,
    "applyAttempts" integer DEFAULT 0 NOT NULL,
    "lastError" character varying(1000),
    "nextAttemptAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "requestUserId" text NOT NULL,
    "approverUserId" text
);


ALTER TABLE public."PolicyExceptionRequest" OWNER TO devuser;

--
-- Name: RefreshToken; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."RefreshToken" (
    id text NOT NULL,
    "tokenHash" text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "revokedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userId" text NOT NULL
);


ALTER TABLE public."RefreshToken" OWNER TO devuser;

--
-- Name: RolePermission; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."RolePermission" (
    role public."Role" NOT NULL,
    "permissionId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."RolePermission" OWNER TO devuser;

--
-- Name: User; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    "pwdHash" text NOT NULL,
    role public."Role" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "disabledAt" timestamp(3) without time zone
);


ALTER TABLE public."User" OWNER TO devuser;

--
-- Name: UserCluster; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."UserCluster" (
    "userId" text NOT NULL,
    "clusterId" character varying(128) NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."UserCluster" OWNER TO devuser;

--
-- Name: ViolationHistory; Type: TABLE; Schema: public; Owner: devuser
--

CREATE TABLE public."ViolationHistory" (
    id text NOT NULL,
    "policyName" text NOT NULL,
    "ruleName" text NOT NULL,
    "targetClusterId" character varying(128) NOT NULL,
    "targetClusterDisplayName" character varying(253) NOT NULL,
    namespace character varying(63) DEFAULT 'cluster-wide'::character varying NOT NULL,
    "resourceKind" character varying(63) DEFAULT 'Unknown'::character varying NOT NULL,
    "resourceName" character varying(253) DEFAULT 'Unknown'::character varying NOT NULL,
    severity character varying(20) DEFAULT 'medium'::character varying NOT NULL,
    status character varying(20) DEFAULT 'open'::character varying NOT NULL,
    message character varying(2000),
    "occurredAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."ViolationHistory" OWNER TO devuser;

--
-- Data for Name: AuditLog; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."AuditLog" (id, action, "entityType", "entityId", "actorType", "beforeStatus", "afterStatus", metadata, "createdAt", "userId") FROM stdin;
\.


--
-- Data for Name: Notification; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."Notification" (id, title, message, type, severity, href, "targetRoles", "targetUserEmails", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: NotificationRead; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."NotificationRead" ("userId", "notificationId", "readAt") FROM stdin;
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-9c7ed227-e216-4f25-9b9d-5d569dc5dc7b	2026-08-30 13:12:17.903
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-7cb83a86-cd82-4888-85b6-542088335212	2026-08-30 13:12:17.904
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-5425555f-5e68-4252-bbf1-bd21cc68d340	2026-08-30 13:12:17.905
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-1d79cf82-4598-42c7-a415-01e5882bd52f	2026-08-30 13:12:17.906
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-fe1b47ae-31ff-4fe9-8e75-ea1528e33b48	2026-08-30 13:12:17.907
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-5cec1d79-52f0-4c0d-93e3-fb5fc13b5933	2026-08-30 13:12:17.908
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-c2898b11-aca5-4c40-ade1-7d9931a3d44c	2026-08-30 13:12:17.909
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-d5719655-29a1-4269-8d37-a43dbd141193	2026-08-30 13:12:17.91
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-c3667981-b3e1-40f9-8568-8826eea78d8d	2026-08-30 13:12:17.911
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-1d888dcf-3bce-4eff-9949-eacb12e4c1ac	2026-08-30 13:12:20.707
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-b7de0cc4-2156-4de0-980d-13d7e6cd4073	2026-08-30 13:51:25.802
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-95ebde45-7dcf-4cbe-b2b4-115717b3a5a0	2026-08-30 13:51:25.804
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-4f065558-d890-401b-8bd1-3880ea3de8ac	2026-08-30 13:51:25.805
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-7b02f463-c6a2-4684-92ba-44d092cd7814	2026-08-30 13:51:25.806
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-d64dca0e-9bfd-43b9-b339-87dd3d2b9b14	2026-08-30 13:51:25.807
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-f9bfad6b-dbcf-4f10-a14e-3c734e7c9b11	2026-08-30 13:51:25.808
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-b4891b12-b800-4ccf-b31a-a573108abb61	2026-08-30 13:51:25.809
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-7c0cdfa9-ff0b-413f-9d5c-ab09d60497b9	2026-08-30 13:51:25.81
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-fac83261-9bbd-4011-9639-5ce05ad7eede	2026-08-30 13:51:25.811
4f53e52c-90cc-4f9c-a202-8a164a84776f	noti-vio-152cd054-7844-42ba-acfd-308d63cedd1f	2026-08-30 13:51:25.812
\.


--
-- Data for Name: Permission; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."Permission" (id, key, description, "createdAt", "updatedAt") FROM stdin;
9dfc93df-2423-4cf5-8a40-f3c536e3027b	users.read	Read users.	2026-08-30 11:50:41.502	2026-08-30 11:50:41.502
43089720-e316-4b88-9e44-4d7011dd696e	users.create	Create users.	2026-08-30 11:50:41.896	2026-08-30 11:50:41.896
afc02573-9d63-4562-8287-9033fc3d8293	users.update_role	Update user roles.	2026-08-30 11:50:41.898	2026-08-30 11:50:41.898
d4bf870a-d151-44b9-a0d8-8e5aaf7fd3ee	users.disable	Enable or disable users.	2026-08-30 11:50:41.9	2026-08-30 11:50:41.9
11e59f14-a94f-4be7-bd22-678d19f0e73b	users.reset_password	Reset user passwords.	2026-08-30 11:50:41.902	2026-08-30 11:50:41.902
890bccce-fdb2-460e-9332-4df78eee8d54	permissions.read	Read permissions.	2026-08-30 11:50:41.904	2026-08-30 11:50:41.904
19c8dfdf-eba9-4a45-b94d-cf42ba308fe4	violations.read	Read policy violations.	2026-08-30 11:50:41.905	2026-08-30 11:50:41.905
faa01df0-61aa-4075-866a-0b11ef9f2f00	exception_requests.read	Read policy exception requests.	2026-08-30 11:50:42.047	2026-08-30 11:50:42.047
deacdc56-e330-4ab3-accc-d37268507950	exception_requests.create	Create policy exception requests.	2026-08-30 11:50:42.049	2026-08-30 11:50:42.049
77489246-b2c0-4e36-8088-82f2dcc4a2b4	exception_requests.approve	Approve policy exception requests.	2026-08-30 11:50:42.051	2026-08-30 11:50:42.051
107a7e16-9817-40a1-89dc-f392406f0770	exception_requests.reject	Reject policy exception requests.	2026-08-30 11:50:42.053	2026-08-30 11:50:42.053
c688f91f-37bf-4468-a6ed-b75471be545d	exception_requests.cancel	Cancel policy exception requests.	2026-08-30 11:50:42.054	2026-08-30 11:50:42.054
65b85318-41ca-46c3-a280-79766c4ddbca	exception_requests.retry	Retry failed policy exception requests.	2026-08-30 11:50:42.056	2026-08-30 11:50:42.056
1703b1b0-2828-4746-bcb3-1f65d9fe1112	exception_requests.expire	Expire policy exception requests.	2026-08-30 11:50:42.195	2026-08-30 11:50:42.195
bf2f2258-67a6-42aa-8334-bb63b8aa22b5	users.assign_clusters	Assign clusters to users.	2026-08-30 11:50:42.197	2026-08-30 11:50:42.197
494ac663-7cc5-4739-85a6-bce9284d0fd0	policies.read	Read Kyverno policies.	2026-08-30 11:50:42.199	2026-08-30 11:50:42.199
d419bc07-4ce0-48dc-afef-e0d63e6ab2c9	audit_logs.read	Read audit logs.	2026-08-30 11:50:42.201	2026-08-30 11:50:42.201
587bce34-0bf3-4f40-9538-d5439526cf00	notifications.read	Read user notifications.	2026-08-30 11:50:42.202	2026-08-30 11:50:42.202
27a13c59-7222-445c-add7-80bd67815b44	mlops.notebooks	Manage MLOps Kubeflow Notebooks.	2026-08-30 11:50:42.204	2026-08-30 11:50:42.204
129167c5-e7a4-4f78-b392-a9397fad62e0	mlops.governance	Manage MLOps Governance & FinOps.	2026-08-30 11:50:42.206	2026-08-30 11:50:42.206
6642e72e-d4b4-4251-9d09-a8f8fd5807ab	mlops.pipelines	Manage MLOps Kubeflow Pipelines.	2026-08-30 11:50:42.207	2026-08-30 11:50:42.207
bc797de2-e91d-4e7e-bb98-f032b4b8e870	mlops.serving	Manage MLOps Model Serving Center.	2026-08-30 11:50:42.346	2026-08-30 11:50:42.346
\.


--
-- Data for Name: PolicyExceptionRequest; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."PolicyExceptionRequest" (id, status, reason, "policyName", "ruleNames", "appliedRuleNames", "resourceKind", "resourceName", "resourceNamespace", "targetClusterId", "targetClusterDisplayName", "k8sExceptionName", "expiresAt", "decisionNote", "decidedAt", "activatedAt", "applyAttempts", "lastError", "nextAttemptAt", "createdAt", "updatedAt", "requestUserId", "approverUserId") FROM stdin;
\.


--
-- Data for Name: RefreshToken; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."RefreshToken" (id, "tokenHash", "expiresAt", "revokedAt", "createdAt", "updatedAt", "userId") FROM stdin;
c29f8f8d-d7a3-41f1-9e14-1f4b6e42c42b	$argon2id$v=19$m=65536,t=3,p=4$zu7dAwo+dUSINzRMp2BDqQ$GoPyY5miyBgTXWORL0Bnpum0Qa77UFyde+5GWgq6+Zo	2026-09-06 11:53:52.466	\N	2026-08-30 11:53:52.469	2026-08-30 11:53:52.469	4f53e52c-90cc-4f9c-a202-8a164a84776f
b2904538-41d8-4495-b2ff-3221e04732c6	$argon2id$v=19$m=65536,t=3,p=4$8yAbx9ndJUbTCMrXXyu3Wg$KgbqGQG5/5oG9BCtEesH98FCvzvdie6S4y3yobAoY7c	2026-09-06 12:59:36.933	2026-08-30 13:01:21.88	2026-08-30 12:59:36.936	2026-08-30 13:01:21.881	4f53e52c-90cc-4f9c-a202-8a164a84776f
e36bf714-1d28-4eca-90f2-9372cb9d9a34	$argon2id$v=19$m=65536,t=3,p=4$Re3l5RiBnUiZMhpEVkrVTA$2b4+VK0/T/a/cI4FP2OgnzvzYMHWc5bToenIt459AzQ	2026-09-06 13:01:21.878	2026-08-30 13:47:14.375	2026-08-30 13:01:21.883	2026-08-30 13:47:14.376	4f53e52c-90cc-4f9c-a202-8a164a84776f
46b9a0e9-8113-4fc5-a393-267ef3fda649	$argon2id$v=19$m=65536,t=3,p=4$IUM/HSl00fGYLsEnYDfPJw$swx5zagarzYZWjH6dgsyoy+KXvB4HAidjgst0PYUw/U	2026-09-06 13:47:14.373	2026-08-30 14:02:44.75	2026-08-30 13:47:14.378	2026-08-30 14:02:44.751	4f53e52c-90cc-4f9c-a202-8a164a84776f
1adb9b9e-bdc4-490e-95c4-ef9d6e4cc991	$argon2id$v=19$m=65536,t=3,p=4$9hNp4jO6zjkQd7qs5PZJtg$Iay5cJeLHc6fgpXiP1YqdTvbx8x7ysknNUYyvC8nY/s	2026-09-06 14:02:44.748	\N	2026-08-30 14:02:44.752	2026-08-30 14:02:44.752	4f53e52c-90cc-4f9c-a202-8a164a84776f
\.


--
-- Data for Name: RolePermission; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."RolePermission" (role, "permissionId", "createdAt") FROM stdin;
ADMIN	9dfc93df-2423-4cf5-8a40-f3c536e3027b	2026-08-30 11:50:42.348
ADMIN	43089720-e316-4b88-9e44-4d7011dd696e	2026-08-30 11:50:42.359
ADMIN	afc02573-9d63-4562-8287-9033fc3d8293	2026-08-30 11:50:42.365
ADMIN	d4bf870a-d151-44b9-a0d8-8e5aaf7fd3ee	2026-08-30 11:50:42.37
ADMIN	11e59f14-a94f-4be7-bd22-678d19f0e73b	2026-08-30 11:50:42.375
ADMIN	890bccce-fdb2-460e-9332-4df78eee8d54	2026-08-30 11:50:42.517
ADMIN	19c8dfdf-eba9-4a45-b94d-cf42ba308fe4	2026-08-30 11:50:42.524
ADMIN	faa01df0-61aa-4075-866a-0b11ef9f2f00	2026-08-30 11:50:42.53
ADMIN	deacdc56-e330-4ab3-accc-d37268507950	2026-08-30 11:50:42.673
ADMIN	77489246-b2c0-4e36-8088-82f2dcc4a2b4	2026-08-30 11:50:42.679
ADMIN	107a7e16-9817-40a1-89dc-f392406f0770	2026-08-30 11:50:42.685
ADMIN	c688f91f-37bf-4468-a6ed-b75471be545d	2026-08-30 11:50:42.827
ADMIN	65b85318-41ca-46c3-a280-79766c4ddbca	2026-08-30 11:50:42.833
ADMIN	1703b1b0-2828-4746-bcb3-1f65d9fe1112	2026-08-30 11:50:42.838
ADMIN	bf2f2258-67a6-42aa-8334-bb63b8aa22b5	2026-08-30 11:50:42.98
ADMIN	494ac663-7cc5-4739-85a6-bce9284d0fd0	2026-08-30 11:50:42.986
ADMIN	d419bc07-4ce0-48dc-afef-e0d63e6ab2c9	2026-08-30 11:50:42.991
ADMIN	587bce34-0bf3-4f40-9538-d5439526cf00	2026-08-30 11:50:43.134
ADMIN	27a13c59-7222-445c-add7-80bd67815b44	2026-08-30 11:50:43.14
ADMIN	129167c5-e7a4-4f78-b392-a9397fad62e0	2026-08-30 11:50:43.145
ADMIN	6642e72e-d4b4-4251-9d09-a8f8fd5807ab	2026-08-30 11:50:43.287
ADMIN	bc797de2-e91d-4e7e-bb98-f032b4b8e870	2026-08-30 11:50:43.293
APPROVER	494ac663-7cc5-4739-85a6-bce9284d0fd0	2026-08-30 11:50:43.299
APPROVER	19c8dfdf-eba9-4a45-b94d-cf42ba308fe4	2026-08-30 11:50:43.516
APPROVER	faa01df0-61aa-4075-866a-0b11ef9f2f00	2026-08-30 11:50:43.522
APPROVER	77489246-b2c0-4e36-8088-82f2dcc4a2b4	2026-08-30 11:50:43.528
APPROVER	107a7e16-9817-40a1-89dc-f392406f0770	2026-08-30 11:50:43.67
APPROVER	65b85318-41ca-46c3-a280-79766c4ddbca	2026-08-30 11:50:43.675
APPROVER	d419bc07-4ce0-48dc-afef-e0d63e6ab2c9	2026-08-30 11:50:43.681
APPROVER	587bce34-0bf3-4f40-9538-d5439526cf00	2026-08-30 11:50:43.823
APPROVER	129167c5-e7a4-4f78-b392-a9397fad62e0	2026-08-30 11:50:43.829
APPROVER	6642e72e-d4b4-4251-9d09-a8f8fd5807ab	2026-08-30 11:50:43.834
APPROVER	bc797de2-e91d-4e7e-bb98-f032b4b8e870	2026-08-30 11:50:43.977
REQUESTER	494ac663-7cc5-4739-85a6-bce9284d0fd0	2026-08-30 11:50:43.983
REQUESTER	19c8dfdf-eba9-4a45-b94d-cf42ba308fe4	2026-08-30 11:50:43.989
REQUESTER	faa01df0-61aa-4075-866a-0b11ef9f2f00	2026-08-30 11:50:44.131
REQUESTER	deacdc56-e330-4ab3-accc-d37268507950	2026-08-30 11:50:44.136
REQUESTER	c688f91f-37bf-4468-a6ed-b75471be545d	2026-08-30 11:50:44.142
REQUESTER	587bce34-0bf3-4f40-9538-d5439526cf00	2026-08-30 11:50:44.284
REQUESTER	27a13c59-7222-445c-add7-80bd67815b44	2026-08-30 11:50:44.29
REQUESTER	129167c5-e7a4-4f78-b392-a9397fad62e0	2026-08-30 11:50:44.295
REQUESTER	6642e72e-d4b4-4251-9d09-a8f8fd5807ab	2026-08-30 11:50:44.368
REQUESTER	bc797de2-e91d-4e7e-bb98-f032b4b8e870	2026-08-30 11:50:44.374
VIEWER	494ac663-7cc5-4739-85a6-bce9284d0fd0	2026-08-30 11:50:44.517
VIEWER	19c8dfdf-eba9-4a45-b94d-cf42ba308fe4	2026-08-30 11:50:44.523
VIEWER	faa01df0-61aa-4075-866a-0b11ef9f2f00	2026-08-30 11:50:44.529
VIEWER	587bce34-0bf3-4f40-9538-d5439526cf00	2026-08-30 11:50:44.671
VIEWER	129167c5-e7a4-4f78-b392-a9397fad62e0	2026-08-30 11:50:44.677
VIEWER	6642e72e-d4b4-4251-9d09-a8f8fd5807ab	2026-08-30 11:50:44.683
VIEWER	bc797de2-e91d-4e7e-bb98-f032b4b8e870	2026-08-30 11:50:44.825
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."User" (id, email, "pwdHash", role, "createdAt", "updatedAt", "disabledAt") FROM stdin;
4f53e52c-90cc-4f9c-a202-8a164a84776f	admin@test.com	$argon2id$v=19$m=65536,t=3,p=4$EmeJj/SxsRixqJMTUXnKKQ$mBxYt8nTBr28P0FI4P/LFTDxrQYxKyFfcUfpNaewXo0	ADMIN	2026-08-30 11:50:44.892	2026-08-30 11:50:44.892	\N
955e63da-e127-413e-993d-eb852337f59b	user@test.com	$argon2id$v=19$m=65536,t=3,p=4$1yUSDK5u+46c3w2J/i4HMg$UzhsEieYYgt8AOGl0J5oWDAQleE1DyxXJFy5U0oc3NY	REQUESTER	2026-08-30 11:50:45.03	2026-08-30 11:50:45.03	\N
\.


--
-- Data for Name: UserCluster; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."UserCluster" ("userId", "clusterId", "createdAt") FROM stdin;
\.


--
-- Data for Name: ViolationHistory; Type: TABLE DATA; Schema: public; Owner: devuser
--

COPY public."ViolationHistory" (id, "policyName", "ruleName", "targetClusterId", "targetClusterDisplayName", namespace, "resourceKind", "resourceName", severity, status, message, "occurredAt") FROM stdin;
1d79cf82-4598-42c7-a415-01e5882bd52f	disallow-untrusted-ml-images	validate-ml-registries	default	default	default	Unknown	Unknown	medium	open	validation error: 승인되지 않은 레지스트리의 ML 컨테이너 이미지는 사용할 수 없습니다. 사내 승인 레지스트리(ecr.mycompany.com, quay.io/kubeflow, gcr.io/kubeflow-images, nvcr.io 등)를 사용하세요. rule validate-ml-registries failed at path /spec/containers/0/image/	2026-08-30 12:26:22
9faff656-e16f-4df5-b3c9-6ea3073b536e	require-resource-limits	validate-resource-requests-limits	default	default	default	Unknown	Unknown	medium	open	validation error: 모든 컨테이너는 CPU/Memory의 requests 및 limits 설정을 요구합니다. rule validate-resource-requests-limits failed at path /spec/containers/0/resources/limits/	2026-08-30 12:26:22
c2898b11-aca5-4c40-ade1-7d9931a3d44c	disallow-latest-tag	disallow-latest-tag	default	default	default	Unknown	Unknown	medium	open	validation error: ':latest' 태그는 이미지 재현성과 안정성을 보장하지 않으므로 사용할 수 없습니다. 커밋 해시 또는 특정 버전 태그를 사용하세요. rule disallow-latest-tag failed at path /spec/containers/0/image/	2026-08-30 12:26:22
5cec1d79-52f0-4c0d-93e3-fb5fc13b5933	disallow-privileged-containers	disallow-privileged-containers	default	default	governance-testbed	Unknown	Unknown	medium	open	validation error: privileged: true 옵션이 설정된 특권 컨테이너는 보안 정책상 실행될 수 없습니다. rule disallow-privileged-containers failed at path /spec/containers/0/securityContext/privileged/	2026-08-30 12:26:22
fe1b47ae-31ff-4fe9-8e75-ea1528e33b48	require-resource-limits	autogen-validate-resource-requests-limits	default	default	kube-system	Unknown	Unknown	medium	open	validation error: 모든 컨테이너는 CPU/Memory의 requests 및 limits 설정을 요구합니다. rule autogen-validate-resource-requests-limits failed at path /spec/template/spec/containers/0/resources/limits/cpu/	2026-08-30 12:26:22
c3667981-b3e1-40f9-8568-8826eea78d8d	disallow-untrusted-ml-images	validate-ml-registries	default	default	production	Unknown	Unknown	medium	open	validation error: 승인되지 않은 레지스트리의 ML 컨테이너 이미지는 사용할 수 없습니다. 사내 승인 레지스트리(ecr.mycompany.com, quay.io/kubeflow, gcr.io/kubeflow-images, nvcr.io 등)를 사용하세요. rule validate-ml-registries failed at path /spec/containers/0/image/	2026-08-30 12:26:32
0f7f544a-6d03-48c1-a5f8-05f83aeda293	disallow-untrusted-ml-images	validate-ml-registries	default	default	default	Unknown	Unknown	medium	open	validation error: 승인되지 않은 레지스트리의 ML 컨테이너 이미지는 사용할 수 없습니다. 사내 승인 레지스트리(ecr.mycompany.com, quay.io/kubeflow, gcr.io/kubeflow-images, nvcr.io 등)를 사용하세요. rule validate-ml-registries failed at path /spec/containers/0/image/	2026-08-30 12:26:22
5425555f-5e68-4252-bbf1-bd21cc68d340	require-resource-limits	validate-resource-requests-limits	default	default	default	Unknown	Unknown	medium	open	validation error: 모든 컨테이너는 CPU/Memory의 requests 및 limits 설정을 요구합니다. rule validate-resource-requests-limits failed at path /spec/containers/0/resources/limits/	2026-08-30 12:26:22
7cb83a86-cd82-4888-85b6-542088335212	disallow-latest-tag	disallow-latest-tag	default	default	default	Unknown	Unknown	medium	open	validation error: ':latest' 태그는 이미지 재현성과 안정성을 보장하지 않으므로 사용할 수 없습니다. 커밋 해시 또는 특정 버전 태그를 사용하세요. rule disallow-latest-tag failed at path /spec/containers/0/image/	2026-08-30 12:26:22
9c7ed227-e216-4f25-9b9d-5d569dc5dc7b	disallow-privileged-containers	disallow-privileged-containers	default	default	governance-testbed	Unknown	Unknown	medium	open	validation error: privileged: true 옵션이 설정된 특권 컨테이너는 보안 정책상 실행될 수 없습니다. rule disallow-privileged-containers failed at path /spec/containers/0/securityContext/privileged/	2026-08-30 12:26:22
1d888dcf-3bce-4eff-9949-eacb12e4c1ac	disallow-privileged-containers	autogen-disallow-privileged-containers	default	default	kube-system	Unknown	Unknown	medium	open	validation error: privileged: true 옵션이 설정된 특권 컨테이너는 보안 정책상 실행될 수 없습니다. rule autogen-disallow-privileged-containers failed at path /spec/template/spec/containers/0/securityContext/privileged/	2026-08-30 12:26:22
cdd804f8-6f57-4b5e-8551-e3d258e2b0a6	disallow-latest-tag	autogen-disallow-latest-tag	default	default	kyverno-platform	Unknown	Unknown	medium	open	validation error: ':latest' 태그는 이미지 재현성과 안정성을 보장하지 않으므로 사용할 수 없습니다. 커밋 해시 또는 특정 버전 태그를 사용하세요. rule autogen-disallow-latest-tag failed at path /spec/template/spec/containers/0/image/	2026-08-30 12:26:22
d5719655-29a1-4269-8d37-a43dbd141193	disallow-untrusted-ml-images	validate-ml-registries	default	default	production	Unknown	Unknown	medium	open	validation error: 승인되지 않은 레지스트리의 ML 컨테이너 이미지는 사용할 수 없습니다. 사내 승인 레지스트리(ecr.mycompany.com, quay.io/kubeflow, gcr.io/kubeflow-images, nvcr.io 등)를 사용하세요. rule validate-ml-registries failed at path /spec/containers/0/image/	2026-08-30 12:26:32
4f065558-d890-401b-8bd1-3880ea3de8ac	disallow-untrusted-ml-images	validate-ml-registries	default	default	default	Unknown	Unknown	medium	open	validation error: 승인되지 않은 레지스트리의 ML 컨테이너 이미지는 사용할 수 없습니다. 사내 승인 레지스트리(ecr.mycompany.com, quay.io/kubeflow, gcr.io/kubeflow-images, nvcr.io 등)를 사용하세요. rule validate-ml-registries failed at path /spec/containers/0/image/	2026-08-30 13:26:22
f9bfad6b-dbcf-4f10-a14e-3c734e7c9b11	require-resource-limits	validate-resource-requests-limits	default	default	default	Unknown	Unknown	medium	open	validation error: 모든 컨테이너는 CPU/Memory의 requests 및 limits 설정을 요구합니다. rule validate-resource-requests-limits failed at path /spec/containers/0/resources/limits/	2026-08-30 13:26:22
95ebde45-7dcf-4cbe-b2b4-115717b3a5a0	disallow-latest-tag	disallow-latest-tag	default	default	default	Unknown	Unknown	medium	open	validation error: ':latest' 태그는 이미지 재현성과 안정성을 보장하지 않으므로 사용할 수 없습니다. 커밋 해시 또는 특정 버전 태그를 사용하세요. rule disallow-latest-tag failed at path /spec/containers/0/image/	2026-08-30 13:26:22
b4891b12-b800-4ccf-b31a-a573108abb61	disallow-untrusted-ml-images	validate-ml-registries	default	default	default	Unknown	Unknown	medium	open	validation error: 승인되지 않은 레지스트리의 ML 컨테이너 이미지는 사용할 수 없습니다. 사내 승인 레지스트리(ecr.mycompany.com, quay.io/kubeflow, gcr.io/kubeflow-images, nvcr.io 등)를 사용하세요. rule validate-ml-registries failed at path /spec/containers/0/image/	2026-08-30 13:26:22
7b02f463-c6a2-4684-92ba-44d092cd7814	disallow-privileged-containers	disallow-privileged-containers	default	default	governance-testbed	Unknown	Unknown	medium	open	validation error: privileged: true 옵션이 설정된 특권 컨테이너는 보안 정책상 실행될 수 없습니다. rule disallow-privileged-containers failed at path /spec/containers/0/securityContext/privileged/	2026-08-30 13:26:22
d64dca0e-9bfd-43b9-b339-87dd3d2b9b14	disallow-privileged-containers	disallow-privileged-containers	default	default	governance-testbed	Unknown	Unknown	medium	open	validation error: privileged: true 옵션이 설정된 특권 컨테이너는 보안 정책상 실행될 수 없습니다. rule disallow-privileged-containers failed at path /spec/containers/0/securityContext/privileged/	2026-08-30 13:26:22
152cd054-7844-42ba-acfd-308d63cedd1f	require-resource-limits	autogen-validate-resource-requests-limits	default	default	kube-system	Unknown	Unknown	medium	open	validation error: 모든 컨테이너는 CPU/Memory의 requests 및 limits 설정을 요구합니다. rule autogen-validate-resource-requests-limits failed at path /spec/template/spec/containers/0/resources/limits/cpu/	2026-08-30 13:26:23
fac83261-9bbd-4011-9639-5ce05ad7eede	require-resource-limits	autogen-validate-resource-requests-limits	default	default	kube-system	Unknown	Unknown	medium	open	validation error: 모든 컨테이너는 CPU/Memory의 requests 및 limits 설정을 요구합니다. rule autogen-validate-resource-requests-limits failed at path /spec/template/spec/containers/0/resources/limits/cpu/	2026-08-30 13:26:23
7c0cdfa9-ff0b-413f-9d5c-ab09d60497b9	require-resource-limits	autogen-validate-resource-requests-limits	default	default	kube-system	Unknown	Unknown	medium	open	validation error: 모든 컨테이너는 CPU/Memory의 requests 및 limits 설정을 요구합니다. rule autogen-validate-resource-requests-limits failed at path /spec/template/spec/containers/0/resources/limits/cpu/	2026-08-30 13:26:22
b7de0cc4-2156-4de0-980d-13d7e6cd4073	require-resource-limits	autogen-validate-resource-requests-limits	default	default	kube-system	Unknown	Unknown	medium	open	validation error: 모든 컨테이너는 CPU/Memory의 requests 및 limits 설정을 요구합니다. rule autogen-validate-resource-requests-limits failed at path /spec/template/spec/containers/0/resources/limits/cpu/	2026-08-30 13:26:22
278f6bde-1a9e-4018-9274-29e0df322fdf	disallow-privileged-containers	autogen-disallow-privileged-containers	default	default	kube-system	Unknown	Unknown	medium	open	validation error: privileged: true 옵션이 설정된 특권 컨테이너는 보안 정책상 실행될 수 없습니다. rule autogen-disallow-privileged-containers failed at path /spec/template/spec/containers/0/securityContext/privileged/	2026-08-30 13:26:22
1f0a3e81-46a1-4a9d-8641-b15215a93362	disallow-privileged-containers	autogen-disallow-privileged-containers	default	default	kube-system	Unknown	Unknown	medium	open	validation error: privileged: true 옵션이 설정된 특권 컨테이너는 보안 정책상 실행될 수 없습니다. rule autogen-disallow-privileged-containers failed at path /spec/template/spec/containers/0/securityContext/privileged/	2026-08-30 13:26:22
7a75e334-63fc-4a17-9d94-2382fc293334	disallow-latest-tag	autogen-disallow-latest-tag	default	default	kyverno-platform	Unknown	Unknown	medium	open	validation error: ':latest' 태그는 이미지 재현성과 안정성을 보장하지 않으므로 사용할 수 없습니다. 커밋 해시 또는 특정 버전 태그를 사용하세요. rule autogen-disallow-latest-tag failed at path /spec/template/spec/containers/0/image/	2026-08-30 13:26:22
6f87ee2b-6077-4aff-adbd-bb143292fbfb	disallow-latest-tag	autogen-disallow-latest-tag	default	default	kyverno-platform	Unknown	Unknown	medium	open	validation error: ':latest' 태그는 이미지 재현성과 안정성을 보장하지 않으므로 사용할 수 없습니다. 커밋 해시 또는 특정 버전 태그를 사용하세요. rule autogen-disallow-latest-tag failed at path /spec/template/spec/containers/0/image/	2026-08-30 13:26:22
\.


--
-- Name: AuditLog AuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_pkey" PRIMARY KEY (id);


--
-- Name: NotificationRead NotificationRead_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."NotificationRead"
    ADD CONSTRAINT "NotificationRead_pkey" PRIMARY KEY ("userId", "notificationId");


--
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id);


--
-- Name: Permission Permission_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."Permission"
    ADD CONSTRAINT "Permission_pkey" PRIMARY KEY (id);


--
-- Name: PolicyExceptionRequest PolicyExceptionRequest_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."PolicyExceptionRequest"
    ADD CONSTRAINT "PolicyExceptionRequest_pkey" PRIMARY KEY (id);


--
-- Name: RefreshToken RefreshToken_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."RefreshToken"
    ADD CONSTRAINT "RefreshToken_pkey" PRIMARY KEY (id);


--
-- Name: RolePermission RolePermission_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."RolePermission"
    ADD CONSTRAINT "RolePermission_pkey" PRIMARY KEY (role, "permissionId");


--
-- Name: UserCluster UserCluster_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."UserCluster"
    ADD CONSTRAINT "UserCluster_pkey" PRIMARY KEY ("userId", "clusterId");


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: ViolationHistory ViolationHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."ViolationHistory"
    ADD CONSTRAINT "ViolationHistory_pkey" PRIMARY KEY (id);


--
-- Name: AuditLog_createdAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "AuditLog_createdAt_idx" ON public."AuditLog" USING btree ("createdAt");


--
-- Name: AuditLog_entityType_entityId_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "AuditLog_entityType_entityId_idx" ON public."AuditLog" USING btree ("entityType", "entityId");


--
-- Name: AuditLog_userId_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "AuditLog_userId_idx" ON public."AuditLog" USING btree ("userId");


--
-- Name: NotificationRead_userId_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "NotificationRead_userId_idx" ON public."NotificationRead" USING btree ("userId");


--
-- Name: Notification_createdAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "Notification_createdAt_idx" ON public."Notification" USING btree ("createdAt");


--
-- Name: Permission_key_key; Type: INDEX; Schema: public; Owner: devuser
--

CREATE UNIQUE INDEX "Permission_key_key" ON public."Permission" USING btree (key);


--
-- Name: PolicyExceptionRequest_approverUserId_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "PolicyExceptionRequest_approverUserId_idx" ON public."PolicyExceptionRequest" USING btree ("approverUserId");


--
-- Name: PolicyExceptionRequest_policyName_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "PolicyExceptionRequest_policyName_idx" ON public."PolicyExceptionRequest" USING btree ("policyName");


--
-- Name: PolicyExceptionRequest_requestUserId_createdAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "PolicyExceptionRequest_requestUserId_createdAt_idx" ON public."PolicyExceptionRequest" USING btree ("requestUserId", "createdAt");


--
-- Name: PolicyExceptionRequest_status_createdAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "PolicyExceptionRequest_status_createdAt_idx" ON public."PolicyExceptionRequest" USING btree (status, "createdAt");


--
-- Name: PolicyExceptionRequest_status_expiresAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "PolicyExceptionRequest_status_expiresAt_idx" ON public."PolicyExceptionRequest" USING btree (status, "expiresAt");


--
-- Name: PolicyExceptionRequest_status_nextAttemptAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "PolicyExceptionRequest_status_nextAttemptAt_idx" ON public."PolicyExceptionRequest" USING btree (status, "nextAttemptAt");


--
-- Name: PolicyExceptionRequest_targetClusterId_k8sExceptionName_key; Type: INDEX; Schema: public; Owner: devuser
--

CREATE UNIQUE INDEX "PolicyExceptionRequest_targetClusterId_k8sExceptionName_key" ON public."PolicyExceptionRequest" USING btree ("targetClusterId", "k8sExceptionName");


--
-- Name: RefreshToken_expiresAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "RefreshToken_expiresAt_idx" ON public."RefreshToken" USING btree ("expiresAt");


--
-- Name: RefreshToken_revokedAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "RefreshToken_revokedAt_idx" ON public."RefreshToken" USING btree ("revokedAt");


--
-- Name: RefreshToken_tokenHash_key; Type: INDEX; Schema: public; Owner: devuser
--

CREATE UNIQUE INDEX "RefreshToken_tokenHash_key" ON public."RefreshToken" USING btree ("tokenHash");


--
-- Name: RefreshToken_userId_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "RefreshToken_userId_idx" ON public."RefreshToken" USING btree ("userId");


--
-- Name: RolePermission_permissionId_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "RolePermission_permissionId_idx" ON public."RolePermission" USING btree ("permissionId");


--
-- Name: UserCluster_clusterId_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "UserCluster_clusterId_idx" ON public."UserCluster" USING btree ("clusterId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: devuser
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: ViolationHistory_occurredAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "ViolationHistory_occurredAt_idx" ON public."ViolationHistory" USING btree ("occurredAt");


--
-- Name: ViolationHistory_policyName_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "ViolationHistory_policyName_idx" ON public."ViolationHistory" USING btree ("policyName");


--
-- Name: ViolationHistory_severity_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "ViolationHistory_severity_idx" ON public."ViolationHistory" USING btree (severity);


--
-- Name: ViolationHistory_targetClusterId_namespace_occurredAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "ViolationHistory_targetClusterId_namespace_occurredAt_idx" ON public."ViolationHistory" USING btree ("targetClusterId", namespace, "occurredAt");


--
-- Name: ViolationHistory_targetClusterId_occurredAt_idx; Type: INDEX; Schema: public; Owner: devuser
--

CREATE INDEX "ViolationHistory_targetClusterId_occurredAt_idx" ON public."ViolationHistory" USING btree ("targetClusterId", "occurredAt");


--
-- Name: AuditLog AuditLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: NotificationRead NotificationRead_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."NotificationRead"
    ADD CONSTRAINT "NotificationRead_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PolicyExceptionRequest PolicyExceptionRequest_approverUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."PolicyExceptionRequest"
    ADD CONSTRAINT "PolicyExceptionRequest_approverUserId_fkey" FOREIGN KEY ("approverUserId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PolicyExceptionRequest PolicyExceptionRequest_requestUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."PolicyExceptionRequest"
    ADD CONSTRAINT "PolicyExceptionRequest_requestUserId_fkey" FOREIGN KEY ("requestUserId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RefreshToken RefreshToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."RefreshToken"
    ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RolePermission RolePermission_permissionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."RolePermission"
    ADD CONSTRAINT "RolePermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES public."Permission"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserCluster UserCluster_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: devuser
--

ALTER TABLE ONLY public."UserCluster"
    ADD CONSTRAINT "UserCluster_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict TbNJlOMKWXt2ECUW1qM7SdmuD9DiNr2Y3GhgFv6SC9piHwQ7fXQwTAh7HPxI2DG

SET search_path TO public;
ALTER TABLE "PolicyExceptionRequest"
  ADD COLUMN "reconcileClaimId" UUID,
  ADD COLUMN "reconcileLeaseUntil" TIMESTAMP(3);

ALTER TABLE "PolicyExceptionRequest"
  ADD CONSTRAINT "PolicyExceptionRequest_reconcile_claim_pair_check"
  CHECK (
    ("reconcileClaimId" IS NULL) = ("reconcileLeaseUntil" IS NULL)
  );
-- AlterTable
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "currentSessionId" TEXT;

-- CreateTable
CREATE TABLE IF NOT EXISTS "Notification" (
    "id" TEXT NOT NULL,
    "title" VARCHAR(253) NOT NULL,
    "message" VARCHAR(2000) NOT NULL,
    "type" VARCHAR(50) NOT NULL,
    "severity" VARCHAR(50) NOT NULL,
    "href" VARCHAR(512) NOT NULL,
    "targetRoles" "Role"[],
    "targetUserEmails" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "NotificationRead" (
    "userId" TEXT NOT NULL,
    "notificationId" VARCHAR(128) NOT NULL,
    "readAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "NotificationRead_pkey" PRIMARY KEY ("userId","notificationId")
);

-- AlterTable
ALTER TABLE "ViolationHistory" ADD COLUMN IF NOT EXISTS "namespace" VARCHAR(63) NOT NULL DEFAULT 'cluster-wide';
ALTER TABLE "ViolationHistory" ADD COLUMN IF NOT EXISTS "resourceKind" VARCHAR(63) NOT NULL DEFAULT 'Unknown';
ALTER TABLE "ViolationHistory" ADD COLUMN IF NOT EXISTS "resourceName" VARCHAR(253) NOT NULL DEFAULT 'Unknown';
ALTER TABLE "ViolationHistory" ADD COLUMN IF NOT EXISTS "severity" VARCHAR(20) NOT NULL DEFAULT 'medium';
ALTER TABLE "ViolationHistory" ADD COLUMN IF NOT EXISTS "status" VARCHAR(20) NOT NULL DEFAULT 'open';
ALTER TABLE "ViolationHistory" ADD COLUMN IF NOT EXISTS "message" VARCHAR(2000);

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Notification_createdAt_idx" ON "Notification"("createdAt");
CREATE INDEX IF NOT EXISTS "NotificationRead_userId_idx" ON "NotificationRead"("userId");
CREATE INDEX IF NOT EXISTS "ViolationHistory_targetClusterId_namespace_occurredAt_idx" ON "ViolationHistory"("targetClusterId", "namespace", "occurredAt");
CREATE INDEX IF NOT EXISTS "ViolationHistory_severity_idx" ON "ViolationHistory"("severity");

-- AddForeignKey
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'NotificationRead_userId_fkey'
  ) THEN
    ALTER TABLE "NotificationRead" ADD CONSTRAINT "NotificationRead_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;
