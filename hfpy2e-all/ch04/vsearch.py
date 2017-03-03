
def search4vowels(phrase : str) -> set:
    """Return any vowels found in a supplied phrase."""
    vowels = set('aeiou')
    return vowels.intersection(set(phrase))


def search4letters(phrase: str, letters: str='aeiou') -> set:
    """Return a set of the 'letters' found in 'phrase'."""
    return set(letters).intersection(set(phrase))


message = input("a string please: ")
print(search4vowels(message))
newVowels = input("New string to search: ")
print(search4letters(message, newVowels))