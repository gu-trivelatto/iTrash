library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_8N2 is
    port (
        clock             : in  std_logic;
        reset             : in  std_logic;
        transmite_dado    : in  std_logic;
        dados_ascii       : in  std_logic_vector (7 downto 0);
        dado_serial       : in  std_logic;
        recebe_dado       : in  std_logic;
        saida_serial      : out std_logic;
        pronto_tx         : out std_logic;
        dado_recebido_rx  : out std_logic_vector (7 downto 0);
        tem_dado          : out std_logic;
        pronto_rx         : out std_logic;
        db_estado_tx      : out std_logic_vector (3 downto 0);
        db_estado_rx      : out std_logic_vector (3 downto 0);
        db_dado_tx        : out std_logic_vector (7 downto 0)
    );
end entity;

architecture uart_8N2_arch of uart_8N2 is

    component tx_serial_8N2 port (
        clock, reset, partida : in  std_logic;
        dados_ascii           : in  std_logic_vector (7 downto 0);
        saida_serial, pronto  : out std_logic;
        db_estado             : out std_logic_vector (3 downto 0)
    );
    end component;

    component rx_serial_8N2 port (
        clock, reset, dado_serial : in  std_logic;
        recebe_dado               : in  std_logic;
        dado_recebido             : out std_logic_vector (7 downto 0);
        pronto_rx, tem_dado       : out std_logic;
        db_estado                 : out std_logic_vector (3 downto 0)
    );
    end component;

    component edge_detector is port ( 
        clk         : in   std_logic;
        signal_in   : in   std_logic;
        output      : out  std_logic
    );
    end component;

    component hex7seg is port (
        hexa: in std_logic_vector (3 downto 0);
        sseg: out std_logic_vector (6 downto 0)
    );
    end component;

    signal s_reset, s_transmite_dado, s_transmite_dado_ed, s_saida_serial, s_pronto_tx : std_logic;
    signal s_dado_serial, s_recebe_dado, s_recebe_dado_ed, s_pronto_rx, s_tem_dado : std_logic;
    signal s_dados_ascii, s_dado_recebido_rx : std_logic_vector (7 downto 0);
    signal s_db_estado_tx_hex, s_db_estado_rx_hex : std_logic_vector (3 downto 0);

begin

    s_reset <= reset;
    s_transmite_dado <= transmite_dado;
    s_dados_ascii <= dados_ascii;
    s_dado_serial <= dado_serial;
    s_recebe_dado <= recebe_dado;
    
    TX: tx_serial_8N2 port map (clock, s_reset, s_transmite_dado_ed, s_dados_ascii, s_saida_serial, s_pronto_tx, s_db_estado_tx_hex);

    RX: rx_serial_8N2 port map (clock, s_reset, s_dado_serial, s_recebe_dado_ed, s_dado_recebido_rx, s_pronto_rx, s_tem_dado, s_db_estado_rx_hex);

    ED_TX: edge_detector port map (clock, s_transmite_dado, s_transmite_dado_ed);

    ED_RX: edge_detector port map (clock, s_recebe_dado, s_recebe_dado_ed);

    saida_serial <= s_saida_serial;
    pronto_tx <= s_pronto_tx;
    dado_recebido_rx <= s_dado_recebido_rx;
    pronto_rx <= s_pronto_rx;
    tem_dado <= s_tem_dado;
    db_estado_tx <= s_db_estado_tx_hex;
    db_estado_rx <= s_db_estado_rx_hex;
    db_dado_tx <= dados_ascii;

end architecture;