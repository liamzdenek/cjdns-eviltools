DROP TABLE IF EXISTS ipv6_3_addr;
DROP TABLE IF EXISTS ipv6_3_data;

CREATE TABLE ipv6_3_addr (
    id BIGINT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    c0 BIT(4), 
    c1 BIT(4),
    c2 BIT(4),
    c3 BIT(4),
    
    c4 BIT(4),
    c5 BIT(4),
    c6 BIT(4),
    c7 BIT(4),
    
    c8 BIT(4),
    c9 BIT(4),
    c10 BIT(4),
    c11 BIT(4),
    
    c12 BIT(4),
    c13 BIT(4),
    c14 BIT(4),
    c15 BIT(4),
    
    
    c16 BIT(4),
    c17 BIT(4),
    c18 BIT(4),
    c19 BIT(4),
    
    c20 BIT(4),
    c21 BIT(4),
    c22 BIT(4),
    c23 BIT(4),
    
    c24 BIT(4),
    c25 BIT(4),
    c26 BIT(4),
    c27 BIT(4),
    
    c28 BIT(4),
    c29 BIT(4),
    c30 BIT(4),
    c31 BIT(4)
);
CREATE TABLE ipv6_3_data (
    id BIGINT PRIMARY KEY NOT NULL,
    privkey CHAR(64),
    iterkey CHAR(64)
);