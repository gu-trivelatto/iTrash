library ieee;
use ieee.std_logic_1164.all;

entity sensor_uc is
    port (
        clock         : in  std_logic;
        reset         : in  std_logic;
        ligar         : in  std_logic;
        aberto        : in  std_logic;
        medida_pronto : in  std_logic;
        mede          : out std_logic;
        estado_hex    : out std_logic_vector(3 downto 0)
    );
end entity;

architecture sensor_uc_arch of sensor_uc is
    type tipo_estado is (inicial, medir);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (aberto, ligar, Eatual) 
    begin

      case Eatual is

        when inicial =>          if aberto='1'   then Eprox <= inicial;
                                 elsif ligar='1' then Eprox <= medir;
                                 else                 Eprox <= inicial;
                                 end if;

        when medir =>            if aberto='1'           then Eprox <= inicial;
                                 elsif medida_pronto='1' then Eprox <= inicial;
                                 else                         Eprox <= medir;
                                 end if;

        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
		  
	with Eatual select
        mede <= '1' when medir, '0' when others;

    -- logica de estado para o debugger
    process (Eatual)
    begin
        case Eatual is
            when inicial => estado_hex <= "0000";
            when medir => estado_hex <= "0001";
            when others => estado_hex <= "1111";
        end case;
    end process;


end architecture;