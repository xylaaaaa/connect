-- CDB Common User Setup Script
-- Creates common users for testing CDB-mode CDC (connecting to FREE CDB root to monitor TESTPDB).
-- Common users must be prefixed with C## in Oracle multitenant.
-- Must be run as SYSDBA from CDB root.
-- Run via: task cdb:setup
--
-- After running, configure the connector with:
--   connection_string: oracle://c##testdb:testdb123@localhost:1521/FREE
--   pdb_name: TESTPDB

ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
/

-- ============================================================================
-- STAGE 1: Create C##TESTDB - application user for CDB-mode connector
-- ============================================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== STAGE 1: Creating C##TESTDB ===');
END;
/

DECLARE
    user_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO user_exists FROM cdb_users WHERE username = 'C##TESTDB' AND con_id = 1;

    IF user_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER c##testdb IDENTIFIED BY testdb123 CONTAINER=ALL';
        EXECUTE IMMEDIATE 'GRANT CONNECT TO c##testdb CONTAINER=ALL';
        EXECUTE IMMEDIATE 'GRANT DBA TO c##testdb CONTAINER=ALL';
        EXECUTE IMMEDIATE 'GRANT LOGMINING TO c##testdb CONTAINER=ALL';
        EXECUTE IMMEDIATE 'GRANT SELECT ANY DICTIONARY TO c##testdb CONTAINER=ALL';
        EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO c##testdb CONTAINER=ALL';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_LOGMNR TO c##testdb CONTAINER=ALL';
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_LOGMNR_D TO c##testdb CONTAINER=ALL';
        DBMS_OUTPUT.PUT_LINE('Common user C##TESTDB created');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Common user C##TESTDB already exists');
    END IF;
END;
/

-- ============================================================================
-- STAGE 2: Create C##RPCN - checkpoint cache schema for CDB-mode connector
-- ============================================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== STAGE 2: Creating C##RPCN ===');
END;
/

DECLARE
    user_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO user_exists FROM cdb_users WHERE username = 'C##RPCN' AND con_id = 1;

    IF user_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER c##rpcn IDENTIFIED BY rpcn123 CONTAINER=ALL';
        EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO c##rpcn CONTAINER=ALL';
        EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO c##rpcn CONTAINER=ALL';
        DBMS_OUTPUT.PUT_LINE('Common user C##RPCN created');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Common user C##RPCN already exists');
    END IF;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== CDB user setup complete ===');
    DBMS_OUTPUT.PUT_LINE('Connection string : oracle://c##testdb:testdb123@localhost:1521/FREE');
    DBMS_OUTPUT.PUT_LINE('pdb_name config   : TESTPDB');
    DBMS_OUTPUT.PUT_LINE('Checkpoint cache  : C##RPCN.CDC_CHECKPOINT_TESTPDB (auto-created by connector)');
    DBMS_OUTPUT.PUT_LINE('Tables monitored  : TESTDB.USERS, TESTDB.PRODUCTS, TESTDB.CART (in TESTPDB)');
END;
/
