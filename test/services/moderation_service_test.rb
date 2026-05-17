require "test_helper"

class ModerationServiceTest < ActiveSupport::TestCase
  setup do
    ModerationService.clear_cache!
  end

  test "should allow normal words, names and phrases" do
    assert_not ModerationService.inappropriate?("Marcus Silva")
    assert_not ModerationService.inappropriate?("João da Silva")
    assert_not ModerationService.inappropriate?("Gosto de estudar matemática e programação.")
    assert_not ModerationService.inappropriate?("Estou disponível às terças e quintas-feiras à tarde.")
    assert_not ModerationService.inappropriate?("Tenho 5 anos de experiência no ensino superior.")
  end

  test "should block direct matches of inappropriate words" do
    assert ModerationService.inappropriate?("bobo")
    assert ModerationService.inappropriate?("tonto")
    assert ModerationService.inappropriate?("idiota")
    assert ModerationService.inappropriate?("retardado")
  end

  test "should block repeated letters to bypass filter" do
    assert ModerationService.inappropriate?("booooboooo")
    assert ModerationService.inappropriate?("tooonto")
    assert ModerationService.inappropriate?("idiiioootaaa")
    assert ModerationService.inappropriate?("reeetardaaado")
  end

  test "should block spaces between letters to bypass filter" do
    assert ModerationService.inappropriate?("b o b o")
    assert ModerationService.inappropriate?("t o n t o")
    assert ModerationService.inappropriate?("i d i o t a")
  end

  test "should block symbols, dots and hyphens between letters" do
    assert ModerationService.inappropriate?("b.o-b_o")
    assert ModerationService.inappropriate?("t*o*n*t*o")
    assert ModerationService.inappropriate?("i.d.i.o.t.a")
    assert ModerationService.inappropriate?("r_e_t_a_r_d_a_d_o")
  end

  test "should block numbers instead of letters (leetspeak)" do
    assert ModerationService.inappropriate?("b0b0")
    assert ModerationService.inappropriate?("t0nt0")
    assert ModerationService.inappropriate?("1d10t4")
    assert ModerationService.inappropriate?("r3t4rd4d0")
  end

  test "should block Cyrillic and Greek homoglyphs lookalikes" do
    # 'і', 'о', 'а' are Cyrillic characters lookalikes
    assert ModerationService.inappropriate?("іdіоtа")
    # 'b' lookalike Cyrillic 'в' and Greek 'ο'
    assert ModerationService.inappropriate?("вοвο")
  end

  test "should block short offensive phrases" do
    assert ModerationService.inappropriate?("filho da puta")
    assert ModerationService.inappropriate?("vai tomar no cu")
    assert ModerationService.inappropriate?("vai se foder")
  end

  test "should avoid false positives on legitimate substrings (Scunthorpe problem)" do
    # "Marcus" contains "cu" as substring but should not be blocked because it's a normal name
    assert_not ModerationService.inappropriate?("Marcus")
    # "documento" contains "cu" but should be allowed
    assert_not ModerationService.inappropriate?("documento")
    # "culinária" contains "cu" but should be allowed
    assert_not ModerationService.inappropriate?("culinária")
    # "acumulado" contains "cu" but should be allowed
    assert_not ModerationService.inappropriate?("acumulado")
  end

  test "should block plural or minor suffixes of offensive words" do
    assert ModerationService.inappropriate?("bobos")
    assert ModerationService.inappropriate?("idiotas")
  end
end
