library ieee;
use ieee.std_logic_1164.all;

entity tx_dados_sonar_uc is
    port (
        clock, reset, transmitir, tick, fim, pronto_tx : in std_logic;
        pronto, transmite, zera, proximo : out std_logic;
        estado_hex : out std_logic_vector (3 downto 0)
    );
end entity;

architecture tx_dados_sonar_uc_arch of tx_dados_sonar_uc is

    type tipo_estado is (inicial, preparacao, espera, atualiza_dado, transmissao, testa_fim, final);
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
    process (transmitir, tick, fim, pronto_tx, Eatual) 
    begin

      case Eatual is

        when inicial =>          if transmitir='1' then Eprox <= preparacao;
                                 else                   Eprox <= inicial;
                                 end if;

        when preparacao =>       Eprox <= espera;

        when espera =>           if tick='1' then   Eprox <= transmissao;
                                 else               Eprox <= espera;
                                 end if;

        when transmissao =>      if pronto_tx='1' then Eprox <= testa_fim;
                                 end if; 

        when testa_fim =>        if fim='1' then Eprox <= final;
                                 else            Eprox <= atualiza_dado;
                                 end if;

        when atualiza_dado =>    Eprox <= espera;

        when final =>            Eprox <= inicial;

        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        proximo <= '1' when atualiza_dado, '0' when others;

    with Eatual select
        transmite <= '1' when transmissao, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    -- logica de estado para o debugger
    process (Eatual)
    begin
        case Eatual is
            when inicial => estado_hex <= "0000";
            when preparacao => estado_hex <= "0001";
            when espera => estado_hex <= "0010";
            when transmissao => estado_hex <= "0011";
            when testa_fim => estado_hex <= "0100";
            when atualiza_dado => estado_hex <= "0101";            
            when final => estado_hex <= "0110";
            when others => estado_hex <= "1111";
        end case;
    end process;

end tx_dados_sonar_uc_arch;