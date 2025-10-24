from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .models import Book

class BookTests(APITestCase):
    def setUp(self):
        self.book_data = {
            'title': 'Test Book',
            'author': 'Test Author',
            'published_date': '2023-01-01',
            'isbn': '1234567890123',
            'pages': 100
        }
        self.book = Book.objects.create(**self.book_data)
    
    def test_create_book(self):
        url = reverse('book-list')
        new_book_data = {
            'title': 'New Book',
            'author': 'New Author',
            'published_date': '2023-02-01',
            'isbn': '1234567890124',
            'pages': 200
        }
        response = self.client.post(url, new_book_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Book.objects.count(), 2)
    
    def test_get_books(self):
        url = reverse('book-list')
        response = self.client.get(url, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
    
    def test_get_book_detail(self):
        url = reverse('book-detail', args=[self.book.id])
        response = self.client.get(url, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], self.book_data['title'])
    
    def test_update_book(self):
        url = reverse('book-detail', args=[self.book.id])
        updated_data = self.book_data.copy()
        updated_data['title'] = 'Updated Book'
        response = self.client.put(url, updated_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.book.refresh_from_db()
        self.assertEqual(self.book.title, 'Updated Book')
    
    def test_delete_book(self):
        url = reverse('book-detail', args=[self.book.id])
        response = self.client.delete(url, format='json')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(Book.objects.count(), 0)
    
    def test_validation_pages_positive(self):
        url = reverse('book-list')
        invalid_data = self.book_data.copy()
        invalid_data['pages'] = -1
        invalid_data['isbn'] = '1234567890125'
        response = self.client.post(url, invalid_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)