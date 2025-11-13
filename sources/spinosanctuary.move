/*
/// Module: spinosanctuary
module spinosanctuary::spinosanctuary;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions
module spinosanctuary::spinosanctuary {
	use std::vector;

  struct Spinosaurus has key {
    id: u64,
    nome: vector<u8>,
    versao: u16,
    tipo: vector<u8>
    saude: u8,
    fome: u8,
  }

  struct Habitat has key {
    nome: vector<u8>,
		tipo: vector<u8>,
		capacidade: u8,
		spinos: vector<Spinosaurus>,
  }

	public entry fun criar_habitat(account: &signer, nome: vector<u8>, tipo: vector<u8>, capacidade: u8) {
		let novo_habitat = Habitat { nome, tipo, capacidade, spinos: vector::empty<Spinosaurus>() };
		move_to(account, novo_habitat);
	}

	public entry fun criar_spino(account: &signer, id: u64, nome: vector<u8>, versao: u16, tipo: vector<u8>) {
		let spino = Spinosaurus { id, nome, tipo, saude: 100, fome: 0 };
		move_to(account, spino);
	}

	public entry fun adicionar_spino(account: &signer) {
		let spino = move_from<Spinosaurus>(signer::address_of(account));
		let habitat = borrow_global_mut<Habitat>(signer::address_of(account));
		assert!(vector::length(&habitat.spinos) < (habitat.capacidade as u64), 1);
		assert!(habitat.tipo == spino.tipo, 2);
		vector::push_back(&mut habitat.spinos, spino);
	}

	public entry fun atualizar_spino(account: &signer, nova_saude: u8, nova_fome: u8) {
		let habitat = borrow_global_mut<Habitat>(signer::address_of(account));
		let i = 0;
		while (i < vector::length(&habitat.spinos)) {
			let spino_ref = vector::borrow_mut(&mut habitat.spinos, i);
			spino_ref.saude = nova_saude;
			spino_ref.fome = nova_fome;
			i = i + 1;
		}
	}
}

