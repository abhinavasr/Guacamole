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

-- Table of arbitrary user attributes. Each attribute is simply a name/value
-- pair associated with a user. Arbitrary attributes are defined by other
-- extensions. Attributes defined by this extension will be mapped to
-- property-typed columns of a specific table.
--

CREATE TABLE guacamole_user_attribute (
    user_id         integer       NOT NULL,
    attribute_name  varchar(128)  NOT NULL,
    attribute_value varchar(4096) NOT NULL,
    
    PRIMARY KEY (user_id, attribute_name),
    
    CONSTRAINT guacamole_user_attribute_ibfk_1
        FOREIGN KEY (user_id)
        REFERENCES guacamole_user (user_id) ON DELETE CASCADE
);

CREATE INDEX guacamole_user_attribute_user_id
    ON guacamole_user_attribute(user_id);
