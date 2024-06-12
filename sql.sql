CREATE TABLE IF NOT EXISTS Domas_IC_Codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(255) NOT NULL,
    unique_code BOOLEAN,
    times INT
);

CREATE TABLE IF NOT EXISTS Domas_IC_Players (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player VARCHAR(255) NOT NULL,
    code VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Domas_IC_Referrals (
    owner VARCHAR(250) NOT NULL,
    ref_money INT(10) NOT NULL DEFAULT 0,
    ref_times INT(10) NOT NULL DEFAULT 0,
    PRIMARY KEY (owner)
);
