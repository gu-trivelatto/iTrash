library ieee;
use ieee.std_logic_1164.all;

entity modulo_medida_uc is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        tx_pronto    : in  std_logic;
        timer_end    : in  std_logic;
        medir        : out std_logic;
        transmitir   : out std_logic;
        contar       : out std_logic;
		  reset_sensor : out std_logic;
        estado_hex   : out std_logic_vector (3 downto 0);
        pronto_rx : in std_logic;
        receber : out std_logic
    );
end entity;

architecture modulo_medida_uc_arch of modulo_medida_uc is

    type tipo_estado is (espera, mede, recebe, transmite);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= espera;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (tx_pronto, pronto_rx, Eatual) 
    begin

      case Eatual is

        when espera =>      if timer_end='1' then Eprox <= mede;
                            else                  Eprox <= espera;
                            end if;

        when mede =>        Eprox <= recebe;

        when recebe =>      if pronto_rx='1' then Eprox <= transmite;
                            else                  Eprox <= recebe;
                            end if; 
                            
        when transmite =>   if tx_pronto='1' then Eprox <= mede;
                            else                  Eprox <= transmite;
                            end if;

        when others =>      Eprox <= mede;

      end case;

    end process;

    -- logica de saida (Moore)
    with Eatual select
        contar <= '1' when espera, '0' when others;
		  
	 with Eatual select
		reset_sensor <= '1' when espera, '0' when others;

    with Eatual select
        medir <= '1' when mede, '0' when others;

    with Eatual select
        receber <= '1' when recebe, '0' when others;

    with Eatual select
        transmitir <= '1' when transmite, '0' when others;

    -- logica de estado para o debugger
    process (Eatual)
    begin
        case Eatual is
            when espera => estado_hex <= "0000";
            when mede => estado_hex <= "0001";
            when recebe => estado_hex <= "0010";
            when transmite => estado_hex <= "0011";
            when others => estado_hex <= "1111";
        end case;
    end process;

end modulo_medida_uc_arch;