/*
/// Module: spinosanctuary
module spinosanctuary::spinosanctuary;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions
module spinosanctuary::spinosanctuary {
	use sui::object::{Self, UID};
	use sui::tx_context::{Self, TxContext};
	use sui::transfer;
	use std::vector;
	use std::string::{Self, String};

	// Valores de saúde (0 = morto, 100 = saudável, 150 = bônus)
	const SAUDE_MINIMA: u8 = 0;
	const SAUDE_NORMAL: u8 = 100;
	const SAUDE_MAXIMA_BONUS: u8 = 150;

	// Valores de fome (0 = sem fome, 100 = faminto, 150 = morrendo de fome)
	const FOME_MINIMA: u8 = 0;
	const FOME_NORMAL: u8 = 100;
	const FOME_MAXIMA_CRITICA: u8 = 150;

	// Código de Erro:
	const E_HABITAT_CHEIO: u64 = 1;
	const E_TIPO_INCOMPATIVEL: u64 = 2; 
	const E_SAUDE_INVALIDA: u64 = 3;
	const E_FOME_INVALIDA: u64 = 4;

	// Struct:
	public struct Spinosaurus has key, store {
		id: UID,
		nome: String,
		versao: String,
		tipo: String,
		saude: u8,
		fome: u8,
	}

	public struct Habitat has key {
		id: UID,
		nome: String,
		tipo: String,
		capacidade: u8,
		spinos: vector<Spinosaurus>,
	}

	// Funções:
	public entry fun criar_habitat(
		nome: vector<u8>,
		tipo: vector<u8>,
		capacidade: u8,
		ctx: &mut TxContext,
	) {
		let novo_habitat = Habitat { id: object::new(ctx), nome: string::utf8(nome), tipo: string::utf8(tipo), capacidade, spinos: vector::empty<Spinosaurus>() };
		transfer::share_object(novo_habitat);
	}

	public fun criar_spino(
		nome: vector<u8>,
		versao: vector<u8>,
		tipo: vector<u8>,
		ctx: &mut TxContext,
	) {
		let spino = Spinosaurus { id: object::new(ctx), nome: string::utf8(nome), versao: string::utf8(versao), tipo: string::utf8(tipo), saude: 100, fome: 0 };
		transfer::transfer(spino, tx_context::sender(ctx));
	}

	public fun adicionar_spino(habitat: &mut Habitat, spino: Spinosaurus) {
		assert!(vector::length(&habitat.spinos) < (habitat.capacidade as u64), E_HABITAT_CHEIO);
		assert!(habitat.tipo == spino.tipo, E_TIPO_INCOMPATIVEL);
		vector::push_back(&mut habitat.spinos, spino);
	}

	public fun atualizar_spino(habitat: &mut Habitat, nova_saude: u8, nova_fome: u8) {
		assert!(nova_saude >= SAUDE_MINIMA && nova_saude <= SAUDE_MAXIMA_BONUS, E_SAUDE_INVALIDA);
		assert!(nova_fome >= FOME_MINIMA && nova_fome <= FOME_MAXIMA_CRITICA, E_FOME_INVALIDA);

		let mut i = 0;
		let len = vector::length(&habitat.spinos);
		while (i < len) {
			let spino_ref = vector::borrow_mut(&mut habitat.spinos, i);
			spino_ref.saude = nova_saude;
			spino_ref.fome = nova_fome;
			i = i + 1;
		}
	}

	public fun get_spino_info(spino: &Spinosaurus): (String, String, String, u8, u8) {
		(spino.nome, spino.versao, spino.tipo, spino.saude, spino.fome)
	}

	public fun get_habitat_info(habitat: &Habitat): (String, String, u8, u64) {
		(habitat.nome, habitat.tipo, habitat.capacidade, vector::length(&habitat.spinos))
	}
}
