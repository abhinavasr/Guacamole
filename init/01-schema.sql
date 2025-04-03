--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.
--

--
-- Connection group table
--

CREATE TABLE guacamole_connection_group (

  connection_group_id   serial       NOT NULL,
  parent_id             integer,
  connection_group_name varchar(128) NOT NULL,
  type                  varchar(32)  NOT NULL DEFAULT 'ORGANIZATIONAL',
  max_connections       integer,
  max_connections_per_user integer,
  enable_session_affinity boolean NOT NULL DEFAULT FALSE,

  PRIMARY KEY (connection_group_id),
  CONSTRAINT connection_group_name_parent
    UNIQUE (connection_group_name, parent_id),

  CONSTRAINT guacamole_connection_group_ibfk_1
    FOREIGN KEY (parent_id)
    REFERENCES guacamole_connection_group (connection_group_id)
    ON DELETE CASCADE

);

CREATE INDEX ON guacamole_connection_group(parent_id);

--
-- Connection table
--

CREATE TABLE guacamole_connection (

  connection_id       serial       NOT NULL,
  connection_name     varchar(128) NOT NULL,
  parent_id           integer,
  protocol            varchar(32)  NOT NULL,
  
  -- Guacamole proxy (guacd) overrides
  proxy_port              integer,
  proxy_hostname          varchar(512),
  proxy_encryption_method varchar(32),

  -- Concurrency limits
  max_connections          integer,
  max_connections_per_user integer,

  -- Load-balancing behavior
  connection_weight        integer,
  failover_only            boolean NOT NULL DEFAULT FALSE,

  PRIMARY KEY (connection_id),
  CONSTRAINT connection_name_parent
    UNIQUE (connection_name, parent_id),

  CONSTRAINT guacamole_connection_ibfk_1
    FOREIGN KEY (parent_id)
    REFERENCES guacamole_connection_group (connection_group_id)
    ON DELETE CASCADE

);

CREATE INDEX ON guacamole_connection(parent_id);

--
-- Connection parameter table
--

CREATE TABLE guacamole_connection_parameter (

  connection_id   integer       NOT NULL,
  parameter_name  varchar(128)  NOT NULL,
  parameter_value varchar(4096) NOT NULL,

  PRIMARY KEY (connection_id,parameter_name),

  CONSTRAINT guacamole_connection_parameter_ibfk_1
    FOREIGN KEY (connection_id)
    REFERENCES guacamole_connection (connection_id)
    ON DELETE CASCADE

);

CREATE INDEX ON guacamole_connection_parameter(connection_id);

--
-- Sharing profile table
--

CREATE TABLE guacamole_sharing_profile (

  sharing_profile_id    serial       NOT NULL,
  sharing_profile_name  varchar(128) NOT NULL,
  primary_connection_id integer      NOT NULL,

  PRIMARY KEY (sharing_profile_id),
  CONSTRAINT sharing_profile_name_primary
    UNIQUE (sharing_profile_name, primary_connection_id),

  CONSTRAINT guacamole_sharing_profile_ibfk_1
    FOREIGN KEY (primary_connection_id)
    REFERENCES guacamole_connection (connection_id)
    ON DELETE CASCADE

);

CREATE INDEX ON guacamole_sharing_profile(primary_connection_id);

--
-- Sharing profile parameter table
--

CREATE TABLE guacamole_sharing_profile_parameter (

  sharing_profile_id integer       NOT NULL,
  parameter_name     varchar(128)  NOT NULL,
  parameter_value    varchar(4096) NOT NULL,

  PRIMARY KEY (sharing_profile_id, parameter_name),

  CONSTRAINT guacamole_sharing_profile_parameter_ibfk_1
    FOREIGN KEY (sharing_profile_id)
    REFERENCES guacamole_sharing_profile (sharing_profile_id)
    ON DELETE CASCADE

);

CREATE INDEX ON guacamole_sharing_profile_parameter(sharing_profile_id);

--
-- Entity table
--

CREATE TABLE guacamole_entity (

  entity_id     serial                  NOT NULL,
  name          varchar(128)            NOT NULL,
  type          varchar(32)             NOT NULL, -- Either "USER" or "USER_GROUP"

  PRIMARY KEY (entity_id),
  CONSTRAINT guacamole_entity_name_scope
    UNIQUE (type, name)

);

--
-- Entity-related tables
--

CREATE TABLE guacamole_user (

  user_id       serial       NOT NULL,
  entity_id     integer      NOT NULL,

  -- Optionally-salted password
  password_hash bytea        NOT NULL,
  password_salt bytea,
  password_date timestamptz  NOT NULL,

  -- Account disabled/expired status
  disabled      boolean      NOT NULL DEFAULT FALSE,
  expired       boolean      NOT NULL DEFAULT FALSE,

  -- Time-based access restriction
  access_window_start    time,
  access_window_end      time,

  -- Date-based access restriction
  valid_from  date,
  valid_until date,

  -- Timezone used for all date/time comparisons and interpretation
  timezone varchar(64),

  -- Profile information
  full_name           varchar(256),
  email_address       varchar(256),
  organization        varchar(256),
  organizational_role varchar(256),

  PRIMARY KEY (user_id),

  CONSTRAINT guacamole_user_single_entity
    UNIQUE (entity_id),

  CONSTRAINT guacamole_user_entity
    FOREIGN KEY (entity_id)
    REFERENCES guacamole_entity (entity_id)
    ON DELETE CASCADE

);

CREATE TABLE guacamole_user_group (

  user_group_id serial      NOT NULL,
  entity_id     integer     NOT NULL,

  -- Group disabled status
  disabled      boolean     NOT NULL DEFAULT FALSE,

  PRIMARY KEY (user_group_id),

  CONSTRAINT guacamole_user_group_single_entity
    UNIQUE (entity_id),

  CONSTRAINT guacamole_user_group_entity
    FOREIGN KEY (entity_id)
    REFERENCES guacamole_entity (entity_id)
    ON DELETE CASCADE

);

CREATE TABLE guacamole_user_group_member (

  user_group_id    integer       NOT NULL,
  member_entity_id integer       NOT NULL,

  PRIMARY KEY (user_group_id, member_entity_id),

  -- Parent must be a user group
  CONSTRAINT guacamole_user_group_member_parent
    FOREIGN KEY (user_group_id)
    REFERENCES guacamole_user_group (user_group_id) ON DELETE CASCADE,

  -- Member may be either a user or a user group (any entity)
  CONSTRAINT guacamole_user_group_member_entity
    FOREIGN KEY (member_entity_id)
    REFERENCES guacamole_entity (entity_id) ON DELETE CASCADE

);

CREATE INDEX ON guacamole_user_group_member(user_group_id);
CREATE INDEX ON guacamole_user_group_member(member_entity_id);

--
-- Permission tables
--

CREATE TABLE guacamole_system_permission (

  entity_id  integer NOT NULL,
  permission varchar(32) NOT NULL,

  PRIMARY KEY (entity_id, permission),

  CONSTRAINT guacamole_system_permission_entity
    FOREIGN KEY (entity_id)
    REFERENCES guacamole_entity (entity_id) ON DELETE CASCADE

);

CREATE INDEX ON guacamole_system_permission(entity_id);

CREATE TABLE guacamole_connection_permission (

  entity_id     integer NOT NULL,
  connection_id integer NOT NULL,
  permission    varchar(32) NOT NULL,

  PRIMARY KEY (entity_id, connection_id, permission),

  CONSTRAINT guacamole_connection_permission_entity
    FOREIGN KEY (entity_id)
    REFERENCES guacamole_entity (entity_id) ON DELETE CASCADE,

  CONSTRAINT guacamole_connection_permission_connection
    FOREIGN KEY (connection_id)
    REFERENCES guacamole_connection (connection_id) ON DELETE CASCADE

);

CREATE INDEX ON guacamole_connection_permission(entity_id);
CREATE INDEX ON guacamole_connection_permission(connection_id);

CREATE TABLE guacamole_connection_group_permission (

  entity_id           integer NOT NULL,
  connection_group_id integer NOT NULL,
  permission          varchar(32) NOT NULL,

  PRIMARY KEY (entity_id, connection_group_id, permission),

  CONSTRAINT guacamole_connection_group_permission_entity
    FOREIGN KEY (entity_id)
    REFERENCES guacamole_entity (entity_id) ON DELETE CASCADE,

  CONSTRAINT guacamole_connection_group_permission_connection_group
    FOREIGN KEY (connection_group_id)
    REFERENCES guacamole_connection_group (connection_group_id) ON DELETE CASCADE

);

CREATE INDEX ON guacamole_connection_group_permission(entity_id);
CREATE INDEX ON guacamole_connection_group_permission(connection_group_id);

CREATE TABLE guacamole_sharing_profile_permission (

  entity_id          integer NOT NULL,
  sharing_profile_id integer NOT NULL,
  permission         varchar(32) NOT NULL,

  PRIMARY KEY (entity_id, sharing_profile_id, permission),

  CONSTRAINT guacamole_sharing_profile_permission_entity
    FOREIGN KEY (entity_id)
    REFERENCES guacamole_entity (entity_id) ON DELETE CASCADE,

  CONSTRAINT guacamole_sharing_profile_permission_sharing_profile
    FOREIGN KEY (sharing_profile_id)
    REFERENCES guacamole_sharing_profile (sharing_profile_id) ON DELETE CASCADE

);

CREATE INDEX ON guacamole_sharing_profile_permission(entity_id);
CREATE INDEX ON guacamole_sharing_profile_permission(sharing_profile_id);

CREATE TABLE guacamole_user_permission (

  entity_id              integer NOT NULL,
  affected_user_id       integer NOT NULL,
  permission             varchar(32) NOT NULL,

  PRIMARY KEY (entity_id, affected_user_id, permission),

  CONSTRAINT guacamole_user_permission_entity
    FOREIGN KEY (entity_id)
    REFERENCES guacamole_entity (entity_id) ON DELETE CASCADE,

  CONSTRAINT guacamole_user_permission_user
    FOREIGN KEY (affected_user_id)
    REFERENCES guacamole_user (user_id) ON DELETE CASCADE

);

CREATE INDEX ON guacamole_user_permission(entity_id);
CREATE INDEX ON guacamole_user_permission(affected_user_id);

CREATE TABLE guacamole_user_group_permission (

  entity_id              integer NOT NULL,
  affected_user_group_id integer NOT NULL,
  permission             varchar(32) NOT NULL,

  PRIMARY KEY (entity_id, affected_user_group_id, permission),

  CONSTRAINT guacamole_user_group_permission_entity
    FOREIGN KEY (entity_id)
    REFERENCES guacamole_entity (entity_id) ON DELETE CASCADE,

  CONSTRAINT guacamole_user_group_permission_user_group
    FOREIGN KEY (affected_user_group_id)
    REFERENCES guacamole_user_group (user_group_id) ON DELETE CASCADE

);

CREATE INDEX ON guacamole_user_group_permission(entity_id);
CREATE INDEX ON guacamole_user_group_permission(affected_user_group_id);

--
-- Connection history
--

CREATE TABLE guacamole_connection_history (

  history_id           serial       NOT NULL,
  user_id              integer      DEFAULT NULL,
  username             varchar(128) NOT NULL,
  remote_host          varchar(256) DEFAULT NULL,
  connection_id        integer      DEFAULT NULL,
  connection_name      varchar(128) NOT NULL,
  sharing_profile_id   integer      DEFAULT NULL,
  sharing_profile_name varchar(128) DEFAULT NULL,
  start_date           timestamptz  NOT NULL,
  end_date             timestamptz  DEFAULT NULL,

  PRIMARY KEY (history_id),

  CONSTRAINT guacamole_connection_history_user
    FOREIGN KEY (user_id)
    REFERENCES guacamole_user (user_id) ON DELETE SET NULL,

  CONSTRAINT guacamole_connection_history_connection
    FOREIGN KEY (connection_id)
    REFERENCES guacamole_connection (connection_id) ON DELETE SET NULL,

  CONSTRAINT guacamole_connection_history_sharing_profile
    FOREIGN KEY (sharing_profile_id)
    REFERENCES guacamole_sharing_profile (sharing_profile_id) ON DELETE SET NULL

);

CREATE INDEX ON guacamole_connection_history(user_id);
CREATE INDEX ON guacamole_connection_history(connection_id);
CREATE INDEX ON guacamole_connection_history(sharing_profile_id);
CREATE INDEX ON guacamole_connection_history(start_date);
CREATE INDEX ON guacamole_connection_history(end_date);

--
-- User password history
--

CREATE TABLE guacamole_user_password_history (

  password_history_id serial  NOT NULL,
  user_id             integer NOT NULL,

  -- Salted password
  password_hash bytea        NOT NULL,
  password_salt bytea,
  password_date timestamptz  NOT NULL,

  PRIMARY KEY (password_history_id),

  CONSTRAINT guacamole_user_password_history_user
    FOREIGN KEY (user_id)
    REFERENCES guacamole_user (user_id) ON DELETE CASCADE

);

CREATE INDEX ON guacamole_user_password_history(user_id);
