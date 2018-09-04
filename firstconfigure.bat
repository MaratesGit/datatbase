#!/bin/bash
dbname="optic_db"
username="postgres"

psql $dbname $username << EOF
INSERT INTO optic_users(
            user_name, pass, perpission)
    VALUES ('system', '23948734yiu34y)_+@#23874293847yiu^%wei37472398yuewry_', 0),
                ('admin', '11111', 1);

EOF

