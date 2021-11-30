library ieee;
use ieee.std_logic_1164.all;

entity itrash_uc is
    port (
        clock      : in  std_logic;
        reset      : in  std_logic;
        lid_open   : in  std_logic;
        mede       : out std_logic;
		  reset_uc   : out std_logic;
        estado_hex : out std_logic_vector(3 downto 0)
    );
end entity;

architecture itrash_uc_arch of itrash_uc is
    type tipo_estado is (fechado, aberto, fechando);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= fechado;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (lid_open, Eatual) 
    begin

      case Eatual is

        when fechado =>          if lid_open='1' then Eprox <= aberto;
                                 else                 Eprox <= fechado;
                                 end if;

        when aberto =>           if lid_open='0'  then Eprox <= fechando;
                                 else                   Eprox <= aberto;
                                 end if;
											
		  when fechando =>         Eprox <= fechado;

        when others =>           Eprox <= fechado;

      end case;

    end process;

    -- logica de saida (Moore)
		  
	with Eatual select
        mede <= '1' when fechado, '0' when others;
		  
	with Eatual select
        reset_uc <= '1' when fechando, '0' when others;
        
    -- logica de estado para o debugger
    process (Eatual)
    begin
        case Eatual is
            when fechado => estado_hex <= "0000";
            when aberto => estado_hex <= "0001";
				when fechando => estado_hex <= "0010";
            when others => estado_hex <= "1111";
        end case;
    end process;


end architecture;