library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity tx_dados_sensor_fd is
    port (
        clock: in std_logic;
        reset: in std_logic;
        transmite: in std_logic;
        proximo: in std_logic;
        distancia2: in std_logic_vector(3 downto 0);
        distancia1: in std_logic_vector(3 downto 0);
        distancia0: in std_logic_vector(3 downto 0);
        saida_serial: out std_logic;
        fim: out std_logic;
        pronto_tx: out std_logic;
		cap_led  : out std_logic_vector(1 downto 0);
		db_dado_tx: out std_logic_vector (7 downto 0);
        db_estado_tx: out std_logic_vector (3 downto 0);
        entrada_serial: in std_logic;
        pronto_rx: out std_logic;
        receber : in std_logic
    );
end entity;

architecture tx_dados_sensor_fd_arch of tx_dados_sensor_fd is
     
    component mux_4x1_n
        generic (
            constant BITS: integer
        );
        port ( 
            D0 :     in  std_logic_vector (BITS-1 downto 0);
            D1 :     in  std_logic_vector (BITS-1 downto 0);
            D2 :     in  std_logic_vector (BITS-1 downto 0);
            D3 :     in  std_logic_vector (BITS-1 downto 0);
            SEL:     in  std_logic_vector (1 downto 0);
            MUX_OUT: out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    component contadorg_m
        generic (
            constant M: integer
        );
        port (
            clock, zera_as, zera_s, conta: in std_logic;
            Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            fim, meio: out std_logic 
        );
    end component;

    component uart_8N2
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
    end component;
    
    signal s_porcentagem0, s_porcentagem1, s_porcentagem2, s_porcento : std_logic_vector (7 downto 0);
    signal s_reset, s_transmite, s_fim, s_proximo, s_saida_serial, s_receber : std_logic;
    signal s_posicao, s_cap_led : std_logic_vector (1 downto 0);
    signal s_mux_out : std_logic_vector (7 downto 0);
	signal s_dado_tx, s_dado_recebido_rx: std_logic_vector (7 downto 0);
    signal s_estado_tx : std_logic_vector (3 downto 0);
    signal s_porcentagem : std_logic_vector (11 downto 0);

begin

    s_porcentagem0 <= "0011" & s_porcentagem(3 downto 0);
    s_porcentagem1 <= "0011" & s_porcentagem(7 downto 4);
    s_porcentagem2 <= "0011" & s_porcentagem(11 downto 8);
    s_porcento <= "00100101";

    s_reset <= reset;
    s_transmite <= transmite;
    s_proximo <= proximo;
    s_receber <= receber;

    MUX: mux_4x1_n generic map (BITS => 8) port map (s_porcentagem0, s_porcentagem1, s_porcentagem2, s_porcento, s_posicao, s_mux_out); 

    UART: uart_8N2 port map (clock, s_reset, s_transmite, s_mux_out, entrada_serial, receber, s_saida_serial, pronto_tx, s_dado_recebido_rx, 
                             open, pronto_rx, s_estado_tx, open, s_dado_tx);

    CONT: contadorg_m generic map (M => 4) port map (clock, s_reset, '0', s_proximo, s_posicao, s_fim, open);

    saida_serial <= s_saida_serial;
    fim <= s_fim;
    db_estado_tx <= s_estado_tx;
    db_dado_tx <= s_dado_tx;
	 cap_led <= s_cap_led;

    process (s_dado_recebido_rx)
    begin
        case s_dado_recebido_rx(7 downto 4) is 
            when "0110" => 
					s_porcentagem <= "000000000000";
					s_cap_led <= "00";
            when "0011" =>
                case s_dado_recebido_rx(3 downto 0) is
                    when "0000" => 
								s_porcentagem <= "000100000000";
								s_cap_led <= "10";
                    when "0001" => 
								s_porcentagem <= "000010010000";
								s_cap_led <= "10";
                    when "0010" => 
								s_porcentagem <= "000010000000";
								s_cap_led <= "01";
                    when "0011" => 
								s_porcentagem <= "000001110000";
								s_cap_led <= "01";
                    when "0100" => 
								s_porcentagem <= "000001100000";
								s_cap_led <= "01";
                    when "0101" => 
								s_porcentagem <= "000001010000";
								s_cap_led <= "01";
                    when "0110" => 
								s_porcentagem <= "000001000000";
								s_cap_led <= "00";
                    when "0111" => 
								s_porcentagem <= "000000110000";
								s_cap_led <= "00";
                    when "1000" => 
								s_porcentagem <= "000000100000";
								s_cap_led <= "00";
                    when "1001" => 
								s_porcentagem <= "000000010000";
								s_cap_led <= "00";
                    when others => 
								s_porcentagem <= "000000000000";
								s_cap_led <= "00";
                end case;
            when others => 
					s_porcentagem <= "000000000000";
					s_cap_led <= "00";
        end case;
    end process;
    
end architecture;