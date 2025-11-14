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
		assert!(vector::length(&habitat.spinos) < (habitat.capacidade as u64), 1);
		assert!(habitat.tipo == spino.tipo, 2);
		vector::push_back(&mut habitat.spinos, spino);
	}

	public fun atualizar_spino(habitat: &mut Habitat, nova_saude: u8, nova_fome: u8) {
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
